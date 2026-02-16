# Annotated Jenkinsfile - browser extension build and deployment

## 1. introduction

The project aim is to create a browser extension available on chrome and firefox

This build allows to:

- lint the project using megalinter and phpstorm inspection
- build necessary docker images
- build firefox and chrome extensions
- deploy firefox extension on s3 bucket
- deploy chrome extension on google play store

## 2. Annotated Jenkinsfile

<!-- markdownlint-disable MD013 -->

```groovy
def credentialsId = 'jenkinsSshCredentialsId'
def lib = library(
    identifier: 'jenkins_library',
    retriever: modernSCM([
        $class: 'GitSCMSource',
        remote: 'git@github.com:fchastanet/jenkins-library.git',
        credentialsId: credentialsId
    ])
)
def docker = lib.fchastanet.Docker.new(this)
def git = lib.fchastanet.Git.new(this)
def mail = lib.fchastanet.Mail.new(this)

def String deploymentBranchTagCompatible = ''
def String gitShortSha = ''
def String REGISTRY_URL = 'dockerRegistryId.dkr.ecr.eu-west-1.amazonaws.com'
def String ECR_BROWSER_EXTENSION_BUILD = 'browser_extension_lint'
def String BUILD_TAG = 'build'
def String PHPSTORM_TAG = 'phpstorm-inspections'
def String REFERENCE_JOB_NAME = 'Browser_extension_deploy'
def String FIREFOX_S3_BUCKET = 'browser-extensions'

// it would have been easier to use checkboxes to avoid 'both'/'none'
// complexity
def DEPLOY_CHROME = (params.targetStore == 'both' || params.targetStore == 'chrome')
def DEPLOY_FIREFOX = (params.targetStore == 'both' || params.targetStore == 'firefox')

pipeline {
  agent {
    node {
      label 'docker-base-ubuntu'
    }
  }
  parameters {
    gitParameter branchFilter: 'origin/(.*)',
      defaultValue: 'master',
      quickFilterEnabled: true,
      sortMode: 'ASCENDING_SMART',
      name: 'BRANCH',
      type: 'PT_BRANCH'

    choice (
      name: 'targetStore',
      choices: ['none', 'both', 'chrome', 'firefox'],
      description: 'Where it should be deployed to? (Default: none, has effect only on master branch)'
    )
  }
  environment {
    GOOGLE_CREDS = credentials('GoogleApiChromeExtension')
    GOOGLE_TOKEN = credentials('GoogleApiChromeExtensionCode')
    GOOGLE_APP_ID = 'googleAppId'
    // provided by https://addons.mozilla.org/en-US/developers/addon/api/key/
    FIREFOX_CREDS = credentials('MozillaApiFirefoxExtension')
    FIREFOX_APP_ID='{d4ce8a6f-675a-4f74-b2ea-7df130157ff4}'
  }

  stages {

    stage("Init") {
      steps {
        script {
          deploymentBranchTagCompatible = docker.getTagCompatibleFromBranch(env.GIT_BRANCH)
          gitShortSha = git.getShortCommitSha(env.GIT_BRANCH)
          echo "Branch ${env.GIT_BRANCH}"
          echo "Docker tag = ${deploymentBranchTagCompatible}"
          echo "git short sha = ${gitShortSha}"
        }
        sh 'echo StrictHostKeyChecking=no >> ~/.ssh/config'
      }
    }

    stage("Lint") {
      agent {
        docker {
          image 'megalinter/megalinter-javascript:v5'
          args "-u root -v ${WORKSPACE}:/tmp/lint --entrypoint=''"
          reuseNode true
        }
      }
      steps {
        sh 'npm install stylelint-config-rational-order'
        sh '/entrypoint.sh'
      }
    }

    stage("Build docker images") {
      steps {
        // whenOrSkip directive is defined in https://github.com/fchastanet/jenkins-library/blob/master/vars/whenOrSkip.groovy
        whenOrSkip(currentBuild.currentResult == "SUCCESS") {
          script {
            docker.pullBuildPushImage(
              buildDirectory:   'build',
              registryImageUrl: "${REGISTRY_URL}/${ECR_BROWSER_EXTENSION_BUILD}",
              tagPrefix:        "${ECR_BROWSER_EXTENSION_BUILD}:",
              tags: [
                "${BUILD_TAG}_${gitShortSha}",
                "${BUILD_TAG}_${deploymentBranchTagCompatible}",
              ],
              pullTags: ["${BUILD_TAG}_master"]
            )
          }
        }
      }
    }

    stage("Build firefox/chrome extensions") {
      steps {
        whenOrSkip(currentBuild.currentResult == "SUCCESS") {
          script {
              sh """
                docker run \
                  -v \$(pwd):/deploy \
                  --rm '${ECR_BROWSER_EXTENSION_BUILD}' \
                  /deploy/build/build-extensions.sh
              """
              // multiple git statuses can be set on a given commit
              // you can configure github to authorize pull request merge
              // based on the presence of one or more github statuses
              git.updateGithubCommitStatus("BUILD_OK")
          }
        }
      }
    }

    stage("Deploy extensions") {
      // deploy both extensions in parallel
      parallel {
        stage("Deploy chrome") {
          steps {
            whenOrSkip(currentBuild.currentResult == "SUCCESS" && DEPLOY_CHROME) {
              // do not fail the entire build if this stage fail
              // so firefox stage can be executed
              catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                script {
                  // best practice: complex sh files have been created outside
                  // of this jenkinsfile deploy-chrome-extension.sh
                  sh """
                  docker run \
                      -v \$(pwd):/deploy \
                      -e APP_CREDS_USR='${GOOGLE_CREDS_USR}' \
                      -e APP_CREDS_PSW='${GOOGLE_CREDS_PSW}' \
                      -e APP_TOKEN='${GOOGLE_APP_TOKEN}' \
                      -e APP_ID='${GOOGLE_APP_ID}' \
                      --rm '${ECR_BROWSER_EXTENSION_BUILD}' \
                      /deploy/build/deploy-chrome-extension.sh
                  """
                  git.updateGithubCommitStatus("CHROME_DEPLOYED")
                }
              }
            }
          }
        }
        stage("Deploy firefox") {
          steps {
            whenOrSkip(currentBuild.currentResult == "SUCCESS" && DEPLOY_FIREFOX) {
              catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                script {
                  // best practice: complex sh files have been created outside
                  // of this jenkinsfile deploy-firefox-extension.sh
                  sh """
                    docker run \
                      -v \$(pwd):/deploy \
                      -e FIREFOX_JWT_ISSUER='${FIREFOX_CREDS_USR}' \
                      -e FIREFOX_JWT_SECRET='${FIREFOX_CREDS_PSW}' \
                      -e FIREFOX_APP_ID='${FIREFOX_APP_ID}' \
                      --rm '${ECR_BROWSER_EXTENSION_BUILD}' \
                      /deploy/build/deploy-firefox-extension.sh
                  """
                  sh """
                    set -x
                    set -o errexit
                    extensionVersion="\$(jq -r .version < package.json)"
                    extensionFilename="tools-\${extensionVersion}-an+fx.xpi"

                    echo "Upload new extension \${extensionFilename} to s3 bucket ${FIREFOX_S3_BUCKET}"
                    aws s3 cp "\$(pwd)/packages/\${extensionFilename}" "s3://${FIREFOX_S3_BUCKET}"
                    aws s3api put-object-acl --bucket "${FIREFOX_S3_BUCKET}" --key "\${extensionFilename}" --acl public-read
                    # url is https://tools.s3.eu-west-1.amazonaws.com/tools-2.5.6-an%2Bfx.xpi

                    echo "Upload new version as current version"
                    aws s3 cp "\$(pwd)/packages/\${extensionFilename}" "s3://${FIREFOX_S3_BUCKET}/tools-an+fx.xpi"
                    aws s3api put-object-acl --bucket "${FIREFOX_S3_BUCKET}" --key "tools-an+fx.xpi" --acl public-read
                    # url is https://tools.s3.eu-west-1.amazonaws.com/tools-an%2Bfx.xpi

                    echo "Upload updates.json file"
                    aws s3 cp "\$(pwd)/packages/updates.json" "s3://${FIREFOX_S3_BUCKET}"
                    aws s3api put-object-acl --bucket "${FIREFOX_S3_BUCKET}" --key "updates.json" --acl public-read
                    # url is https://tools.s3.eu-west-1.amazonaws.com/updates.json
                  """
                  git.updateGithubCommitStatus("FIREFOX_DEPLOYED")
                }
              }
            }
          }
        }
      }
    }
  }
  post {
    always {
      script {
        archiveArtifacts artifacts: 'report/mega-linter.log'
        archiveArtifacts artifacts: 'report/linters_logs/*'
        archiveArtifacts artifacts: 'packages/*', fingerprint: true, allowEmptyArchive: true
        // send email to the builder and culprits of the current commit
        // culprits are the committers since the last commit successfully built
        mail.sendConditionalEmail()
        git.updateConditionalGithubCommitStatus()
      }
    }
    success {
      script {
        if (params.targetStore != 'none' && env.GIT_BRANCH == 'origin/master') {
          // send an email to a teams channel so every collaborators knows
          // when a production ready extension has been deployed
          mail.sendSuccessfulEmail('teamsChannelId.onmicrosoft.com@amer.teams.ms')
        }
      }
    }
  }
}
```

<!-- markdownlint-enable MD013 -->
