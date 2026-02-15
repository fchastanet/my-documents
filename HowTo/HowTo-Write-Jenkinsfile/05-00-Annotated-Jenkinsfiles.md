# Annotated Jenkinsfiles

[Pipeline example](https://www.jenkins.io/doc/book/pipeline/#pipeline-example)

## 1. Simple one

This build is used to generate docker images used to build production code and launch phpunit tests. This pipeline is
parameterized in the Jenkins UI directly with the parameters:

- branch (git branch to use)
- environment(select with 3 options: build, phpunit or all)
  - it would have been better to use simply 2 checkboxes phpunit/build
- project_branch

Here the source code with inline comments:

**Annotated jenkinsfile** Expand source

<!-- markdownlint-disable MD013 -->

```groovy
// This method allows to convert the branch name to a docker image tag.
// This method is generally used by most of my jenkins pipelines, it's why it has been added to https://github.com/fchastanet/jenkins-library/blob/master/src/fchastanet/Docker.groovy#L31
def getTagCompatibleFromBranch(String branchName) {
    def String tag = branchName.toLowerCase()
    tag = tag.replaceAll("^origin/", "")
    return tag.replaceAll('/', '_')
}

// we declare here some variables that will be used in next stages
def String deploymentBranchTagCompatible = ''

pipeline {
    agent {
        node {
            // the pipeline is executed on a machine with docker daemon
            // available
            label 'docker-ubuntu'
        }
    }

    stages {
        stage ('checkout') {
            steps {
                // this command is actually not necessary because checkout is
                // done automatically when using declarative pipeline
                sh 'echo "pulling ... ${GIT_BRANCH#origin/}"'
                checkout scm

                // this particular build needs to access to some private github
                // repositories, so here we are copying the ssh key
                // it would be better to use new way of injecting ssh key
                // inside docker using sshagent
                // check https://stackoverflow.com/a/66897280
                withCredentials([
                    sshUserPrivateKey(
                      credentialsId: '855aad9f-1b1b-494c-aa7f-4de881c7f659',
                      keyFileVariable: 'sshKeyFile'
                   )
                ]) {
                    // best practice similar steps should be merged into one
                    sh 'rm -f ./phpunit/id_rsa'
                    sh 'rm -f ./build/id_rsa'
                    // here we are escaping '$' so the variable will be
                    // interpolated on the jenkins slave and not the jenkins
                    // master node instead of escaping, we could have used
                    // single quotes
                    sh "cp \$sshKeyFile ./phpunit/id_rsa"
                    sh "cp \$sshKeyFile ./build/id_rsa"
                }
                script {
                    // as actually scm is already done before executing the
                    // first step, this call could have been done during
                    // declaration of this variable
                    deploymentBranchTagCompatible = getTagCompatibleFromBranch(GIT_BRANCH)
                }
            }
        }
        stage("build Build env") {
            when {
                // the build can be launched with the parameter environment
                // defined in the configuration of the jenkins job, these
                // parameters could have been defined directly in the pipeline
                // see https://www.jenkins.io/doc/book/pipeline/syntax/#parameters
                expression { return params.environment != "phpunit"}
            }
            steps {
                // here we could have launched all this commands in the same sh
                // directive
                sh "docker build --build-arg BRANCH=${params.project_branch} -t build build"
                // use a constant for dockerRegistryId.dkr.ecr.eu-west-1.amazonaws.com
                sh "docker tag build dockerRegistryId.dkr.ecr.eu-west-1.amazonaws.com/build:${deploymentBranchTagCompatible}"
                sh "docker push dockerRegistryId.dkr.ecr.eu-west-1.amazonaws.com/build:${deploymentBranchTagCompatible}"
            }
        }
        stage("build PHPUnit env") {
            when {
                // it would have been cleaner to use
                // expression { return params.environment = "phpunit"}
                expression { return params.environment != "build"}
            }
            steps {
                sh "docker build --build-arg BRANCH=${params.project_branch} -t phpunit phpunit"
                sh "docker tag phpunit dockerRegistryId.dkr.ecr.eu-west-1.amazonaws.com/phpunit:${deploymentBranchTagCompatible}"
                sh "docker push dockerRegistryId.dkr.ecr.eu-west-1.amazonaws.com/phpunit:${deploymentBranchTagCompatible}"
            }
        }
    }
}
```

<!-- markdownlint-enable MD013 -->

without seeing the Dockerfile files, we can advise :

- to build these images in the same pipeline where build and phpunit are run
  - the images are built at the same time so we are sure that we are using the right version
- apparently the docker build depend on the branch of the project, this should be avoided
- ssh key is used in docker image, that could lead to a **security issue** as ssh key is still in the history of images
  layers even if it has been removed in subsequent layers, check <https://stackoverflow.com/a/66897280> for information
  on how to use ssh-agent instead
- we could use a single Dockerfile with 2 stages:
  - one stage to generate production image
  - one stage that inherits production stage, used to execute phpunit
  - it has the following advantages :
    - reduce the total image size because of the reuse different docker image layers
    - only one Dockerfile to maintain

## 2. More advanced and annotated jenkinsfiles

- [php project with helm push](05-01-Annotated-Jenkinsfiles.md)
- [javascript project with docker build and S3 push](05-02-Annotated-Jenkinsfiles.md)
- [browser extension build and deployment](05-03-Annotated-Jenkinsfiles.md)
- [jenkins library - reusable pipeline generation](05-04-Annotated-Jenkinsfiles.md)
