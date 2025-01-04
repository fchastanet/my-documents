# Annotated Jenkinsfile - php project with helm push

## Introduction

This example is missing the use of parameters, jenkins library in order to reuse
common code

This example uses :

- post conditions
  [https://www.jenkins.io/doc/book/pipeline/syntax/#post](https://www.jenkins.io/doc/book/pipeline/syntax/#post)
- github plugin to set commit status indicating the result of the build
- usage of **several jenkins plugins**, you can check here to get the full list
  installed on your server and even **generate code snippets** by adding
  **pipeline-syntax/** to your jenkins server url

But it misses:

- usage of
  [inline parameters](https://www.jenkins.io/doc/book/pipeline/syntax/#parameters)
- usage of jenkins library to reuse common code
  - [Git updateConditionalGithubCommitStatus](https://github.com/fchastanet/jenkins-library/blob/master/src/fchastanet/Git.groovy#L156)
  - [Docker pullBuildPushImage](https://github.com/fchastanet/jenkins-library/blob/master/src/fchastanet/Docker.groovy#L46)

check
[Pipeline syntax documentation](https://www.jenkins.io/doc/book/pipeline/syntax/)

## Annotated Jenkinsfile

<!-- markdownlint-disable MD013 -->

```groovy
// Define variables for QA environment
def String registry_id = 'awsAccountId'
def String registry_url = registry_id + '.dkr.ecr.us-east-1.amazonaws.com'
def String image_name = 'project'
def String image_fqdn_master = registry_url + '/' + image_name + ':master'
def String image_fqdn_current_branch = image_fqdn_master

// this method is used by several of my pipelines and has been added
// to jenkins_library <https://github.com/fchastanet/jenkins-library/blob/master/src/fchastanet/Git.groovy#L156>
void publishStatusToGithub(String status) {
  step([
    $class: "GitHubCommitStatusSetter",
    reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/fchastanet/project"],
    errorHandlers: [[$class: 'ShallowAnyErrorHandler']],
    statusResultSource: [
      $class: 'ConditionalStatusResultSource',
      results: [
        [$class: 'AnyBuildResult', state: status]
      ]
    ]
  ]);
}

pipeline {
  agent {
    node {
      // bad practice: try to indicate in your node labels, which feature it
      // includes for example, here we need docker, label could have been
      // 'eks-nonprod-docker'
      label 'eks-nonprod'
    }
  }
  stages {
    stage ('Checkout') {
      steps {
        // checkout is not necessary as it is automatically done
        checkout scm

        script {
          // 'wrap' allows to inject some useful variables like BUILD_USER,
          // BUILD_USER_FIRST_NAME
          // see https://www.jenkins.io/doc/pipeline/steps/build-user-vars-plugin/
          wrap([$class: 'BuildUser']) {
            def String displayName = "#${currentBuild.number}_${BRANCH}_${BUILD_USER}_${DEPLOYMENT}"

            // params could have been defined inside the pipeline directly
            // instead of defining them in jenkins build configuration
            if (params.DEPLOYMENT == 'staging') {
              displayName = "${displayName}_${INSTANCE}"
            }
            // next line allows to change the build name, check addHtmlBadge
            // plugin function for more advanced usage of this feature, you
            // check this jenkinsfile 05-02-Annotated-Jenkinsfiles.md
            currentBuild.displayName = displayName
          }
        }
      }
    }
    stage ('Run tests') {
      steps {
        // all these sh directives could have been merged into one
        // it is best to use a separated sh file that could take some parameters
        // as it is simpler to read and to eventually test separately
        sh 'docker build -t project-test "$PWD"/docker/test'
        sh 'cp "$PWD"/app/config/parameters.yml.dist "$PWD"/app/config/parameters.yml'
        // for better readability and if separated script is not possible, use
        // continuation line for better readability
        sh 'docker run -i --rm -v "$PWD":/var/www/html/ -w /var/www/html/ project-test  /bin/bash -c "composer install -a && ./bin/phpunit -c /var/www/html/app/phpunit.xml --coverage-html /var/www/html/var/logs/coverage/ --log-junit /var/www/html/var/logs/phpunit.xml  --coverage-clover /var/www/html/var/logs/clover_coverage.xml"'
      }
      // Run the steps in the post section regardless of the completion status
      // of the Pipeline’s or stage’s run.
      // see https://www.jenkins.io/doc/book/pipeline/syntax/#post
      post {
        always {
          // report unit test reports (unit test should generate result using
          // using junit format)
          junit 'var/logs/phpunit.xml'
          // generate coverage page from test results
          step([
            $class: 'CloverPublisher',
            cloverReportDir: 'var/logs/',
            cloverReportFileName: 'clover_coverage.xml'
          ])
          // publish html page with the result of the coverage
          publishHTML(
            target: [
              allowMissing: false,
              alwaysLinkToLastBuild: false,
              keepAll: true,
              reportDir: 'var/logs/coverage/',
              reportFiles: 'index.html',
              reportName: "Coverage Report"
            ]
          )
        }
      }
    }
    // this stage will be executed only if previous stage is successful
    stage('Build image') {
      when {
        // this stage is executed only if these conditions returns true
        expression {
          return
            params.DEPLOYMENT == "staging"
            || (
              params.DEPLOYMENT == "prod"
              && env.GIT_BRANCH == 'origin/master'
            )
        }
      }
      steps {
        script {
          // this code is used in most of the pipeline and has been centralized
          // in https://github.com/fchastanet/jenkins-library/blob/master/src/fchastanet/Git.groovy#L39
          env.IMAGE_TAG = env.GIT_COMMIT.substring(0, 7)
          // Update variable for production environment
          if ( params.DEPLOYMENT == 'prod' ) {
              registry_id = 'awsDockerRegistryId'
              registry_url = registry_id + '.dkr.ecr.eu-central-1.amazonaws.com'
              image_fqdn_master = registry_url + '/' + image_name + ':master'
          }

          image_fqdn_current_branch = registry_url + '/' + image_name + ':' + env.IMAGE_TAG
        }

        // As jenkins slave machine can be constructed on demand,
        // it doesn't always contains all docker image cache
        // here to avoid building docker image from scratch, we are trying to
        // pull an existing version of the docker image on docker registry
        // and then build using this image as cache, so all layers not updated
        // in Dockerfile will not be built again (gain of time)
        // It is again a recurrent usage in most of the pipelines
        // so the next 8 lines could be replaced by the call to this method
        // Docker
        // pullBuildPushImage https://github.com/fchastanet/jenkins-library/blob/master/src/fchastanet/Docker.groovy#L46

        // Pull the master from repository (|| true avoids errors if the image
        // hasn't been pushed before)
        sh "docker pull ${image_fqdn_master} || true"

        // Build the image using pulled image as cache
        // instead of using concatenation, it is more readable to use variable interpolation
        // Eg: "docker build --cache-from ${image_fqdn_master} -t ..."
        sh 'docker build \
            --cache-from ' + image_fqdn_master + ' \
            -t ' + image_name + ' \
            -f "$PWD/docker/prod/Dockerfile" \
            .'
      }
    }
    stage('Deploy image (Staging)') {
      when {
          expression { return params.DEPLOYMENT == "staging" }
      }

      steps {
        script {
          // Actually we should always push the image in order to be able to
          // feed the docker cache for next builds
          // Again the method Docker pullBuildPushImage https://github.com/fchastanet/jenkins-library/blob/master/src/fchastanet/Docker.groovy#L46
          // solves this issue and could be used instead of the next 6 lines
          // and "Push image (Prod)" stage

          // If building master, we should push the image with the tag master
          // to benefit from docker cache
          if ( env.GIT_BRANCH == 'origin/master' ) {
              sh label:"Tag the image as master",
                 script:"docker tag ${image_name} ${image_fqdn_master}"
              sh label:"Push the image as master",
                 script:"docker push ${image_fqdn_master}"
          }
        }

        sh label:"Tag the image", script:"docker tag ${image_name} ${image_fqdn_current_branch}"
        sh label:"Push the image", script:"docker push ${image_fqdn_current_branch}"
        // use variable interpolation instead of concatenation
        sh label:"Deploy on cluster", script:" \
          helm3 upgrade project-" + params.INSTANCE + " -i \
            --namespace project-" + params.INSTANCE + " \
            --create-namespace \
            --cleanup-on-fail \
            --atomic \
            -f helm/values_files/values-" + params.INSTANCE + ".yaml \
            --set deployment.php_container.image.pullPolicy=Always \
            --set image.tag=" + env.IMAGE_TAG + " \
            ./helm"
      }
    }
    stage('Push image (Prod)') {
      when {
        expression { return params.DEPLOYMENT == "prod" && env.GIT_BRANCH == 'origin/master'}
      }
      // The method Docker pullBuildPushImage https://github.com/fchastanet/jenkins-library/blob/master/src/fchastanet/Docker.groovy#L46
      // provides a generic way of managing the pull, build, push of the docker
      // images, by managing also a common way of tagging docker images
      steps {
        sh label:"Tag the image as master", script:"docker tag ${image_name} ${image_fqdn_current_branch}"
        sh label:"Push the image as master", script:"docker push ${image_fqdn_current_branch}"
      }
    }
  }
  post {
    always {
      // mark github commit as built
      publishStatusToGithub("${currentBuild.currentResult}")
    }
  }
}
```

<!-- markdownlint-enable MD013 -->

This directive is really difficult to read and eventually debug it

<!-- markdownlint-disable MD013 -->

```groovy
sh 'docker run -i --rm -v "$PWD":/var/www/html/ -w /var/www/html/ project-test  /bin/bash -c "composer install -a && ./bin/phpunit -c /var/www/html/app/phpunit.xml --coverage-html /var/www/html/var/logs/coverage/ --log-junit /var/www/html/var/logs/phpunit.xml  --coverage-clover /var/www/html/var/logs/clover_coverage.xml"'
```

<!-- markdownlint-enable MD013 -->

Another way to write previous directive is to:

- use continuation line
- avoid '&&' as it can mask errors, use ';' instead
- use 'set -o errexit' to fail on first error
- use 'set -o pipefail' to fail if eventual piped command is failing
- 'set -x' allows to trace every command executed for better debugging

Here a possible refactoring:

```groovy
sh ''''
  docker run -i --rm \
    -v "$PWD":/var/www/html/ \
    -w /var/www/html/ \
    project-test \
    /bin/bash -c "\
      set -x ;\
      set -o errexit ;\
      set -o pipefail ;\
      composer install -a ;\
      ./bin/phpunit \
        -c /var/www/html/app/phpunit.xml \
        --coverage-html /var/www/html/var/logs/coverage/ \
        --log-junit /var/www/html/var/logs/phpunit.xml  \
        --coverage-clover /var/www/html/var/logs/clover_coverage.xml
    "
'''
```

Note however it is best to use a separated sh file(s) that could take some
parameters as it is simpler to read and to eventually test separately. Here a
refactoring using a separated sh file:

runTests.sh

```bash
#!/bin/bash
set -x -o errexit -o pipefail

composer install -a

./bin/phpunit \
  -c /var/www/html/app/phpunit.xml \
  --coverage-html /var/www/html/var/logs/coverage/ \
  --log-junit /var/www/html/var/logs/phpunit.xml \
  --coverage-clover /var/www/html/var/logs/clover_coverage.xml
```

jenkinsRunTests.sh

```bash
#!/bin/bash
set -x -o errexit -o pipefail

docker build -t project-test "${PWD}/docker/test"

docker run -i --rm \
  -v "${PWD}:/var/www/html/" \
  -w /var/www/html/ \
  project-test \
  runTests.sh
```

Then the sh directive becomes simply

```groovy
sh 'jenkinsRunTests.sh'
```
