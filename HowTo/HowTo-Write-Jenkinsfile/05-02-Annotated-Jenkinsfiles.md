# Annotated Jenkinsfile - javascript project with docker build and S3 push

## Introduction

This build will:

- pull/build/push docker image used to generate project files
- lint
- run Unit tests with coverage
- build the SPA
- run accessibility tests
- build story book and deploy it
- deploy spa on s3 bucket and refresh cloudflare cache

It allows to build for production and qa stages allowing different instances.
Every build contains:

- a summary of the build
  - git branch
  - git revision
  - target environment
- all the available Urls:
  - spa url
  - storybook url

## Annotated Jenkinsfile

<!-- markdownlint-disable MD013 -->

```groovy
// anonymized parameters
String credentialsId = 'jenkinsCredentialId'
def lib = library(
  identifier: 'jenkins_library@v1.0',
  retriever: modernSCM([
    $class: 'GitSCMSource',
    remote: 'git@github.com:fchastanet/jenkins_library.git',
    credentialsId: credentialsId
  ])
)
def docker = lib.fchastanet.Docker.new(this)
def git = lib.fchastanet.Git.new(this)
def mail = lib.fchastanet.Mail.new(this)
def utils = lib.fchastanet.Utils.new(this)
def cloudflare = lib.fchastanet.Cloudflare.new(this)

// anonymized parameters
String CLOUDFLARE_ZONE_ID = 'cloudflareZoneId'
String CLOUDFLARE_ZONE_ID_PROD = 'cloudflareZoneIdProd'
String REGISTRY_ID_QA  = 'dockerRegistryId'
String REACT_APP_PENDO_API_KEY = 'pendoApiKey'

String REGISTRY_QA  = REGISTRY_ID_QA + '.dkr.ecr.us-east-1.amazonaws.com'
String IMAGE_NAME_SPA = 'project-ui'
String STAGING_API_URL = 'https://api.host'
String INSTANCE_URL = "https://${params.instanceName}.host"
String REACT_APP_API_BASE_URL_PROD = 'https://ui.host'
String REACT_APP_PENDO_SOURCE_DOMAIN = 'https://cdn.eu.pendo.io'

String buildBucketPrefix
String S3_PUBLIC_URL = 'qa-spa.s3.amazonaws.com/project'
String S3_PROD_PUBLIC_URL = 'spa.s3.amazonaws.com/project'

List<String> instanceChoices = (1..20).collect { 'project' + it }

Map buildInfo = [
  apiUrl: '',
  storyBookAvailable: false,
  storyBookUrl: '',
  storyBookDocsUrl: '',
  spaAvailable: false,
  spaUrl: '',
  instanceName: '',
]

// add information on summary page
def addBuildInfo(buildInfo) {
  String deployInfo = ''
  if (buildInfo.spaAvailable) {
    String formatInstanceName = buildInfo.instanceName ?
      " (${buildInfo.instanceName})" : '';
    deployInfo += "<a href='${buildInfo.spaUrl}'>SPA${formatInstanceName}</a>"
  }
  if (buildInfo.storyBookAvailable) {
    deployInfo += " / <a href='${buildInfo.storyBookUrl}'>Storybook</a>"
    deployInfo += " / <a href='${buildInfo.storyBookDocsUrl}'>Storybook docs</a>"
  }
  String summaryHtml = """
    <b>branch : </b>${GIT_BRANCH}<br/>
    <b>revision : </b>${GIT_COMMIT}<br/>
    <b>target env : </b>${params.targetEnv}<br/>
    ${deployInfo}
  """
  removeHtmlBadges id: "htmlBadge${currentBuild.number}"
  addHtmlBadge html: summaryHtml, id: "htmlBadge${currentBuild.number}"
}

pipeline {
  agent {
    node {
      // this image has the features docker and lighthouse
      label 'docker-base-ubuntu-lighthouse'
    }
  }

  parameters {
    gitParameter(
      branchFilter: 'origin/(.*)',
      defaultValue: 'main',
      quickFilterEnabled: true,
      sortMode: 'ASCENDING_SMART',
      name: 'BRANCH',
      type: 'PT_BRANCH'
    )
    choice(
      name: 'targetEnv',
      choices: ['none', 'testing', 'production'],
      description: 'Where it should be deployed to? (Default: none - No deploy)'
    )
    booleanParam(
      name: 'buildStorybook',
      defaultValue: false,
      description: 'Build Storybook (will only apply if selected targetEnv is testing)'
    )
    choice(
      name: 'instanceName',
      choices: instanceChoices,
      description: 'Instance name to deploy the revision'
    )
  }

  stages {
    stage('Build SPA image') {
      steps {
        script {
          // set build status to pending on github commit
          step([$class: 'GitHubSetCommitStatusBuilder'])
          wrap([$class: 'BuildUser']) {
            currentBuild.displayName = "#${currentBuild.number}_${BRANCH}_${BUILD_USER}_${targetEnv}"
          }

          branchName = docker.getTagCompatibleFromBranch(env.GIT_BRANCH)
          shortSha = git.getShortCommitSha(env.GIT_BRANCH)

          if (params.targetEnv == 'production') {
            buildBucketPrefix = GIT_COMMIT
            buildInfo.apiUrl = REACT_APP_API_BASE_URL_PROD
            s3BaseUrl = 's3://project-spa/project'
          } else {
            buildBucketPrefix = params.instanceName
            buildInfo.instanceName = params.instanceName
            buildInfo.spaUrl = "${INSTANCE_URL}/index.html"
            buildInfo.apiUrl = STAGING_API_URL
            s3BaseUrl = 's3://project-qa-spa/project'
            buildInfo.storyBookUrl = "${INSTANCE_URL}/storybook/index.html"
            buildInfo.storyBookDocsUrl = "${INSTANCE_URL}/storybook-docs/index.html"
          }
          addBuildInfo(buildInfo)

          // Setup .env
          sh """
            set -x
            echo "REACT_APP_API_BASE_URL = '${buildInfo.apiUrl}'" > ./.env
            echo "REACT_APP_PENDO_SOURCE_DOMAIN = '${REACT_APP_PENDO_SOURCE_DOMAIN}'" >> ./.env
            echo "REACT_APP_PENDO_API_KEY = '${REACT_APP_PENDO_API_KEY}'" >> ./.env
          """

          withCredentials([
            sshUserPrivateKey(
              credentialsId: 'sshCredentialsId',
              keyFileVariable: 'sshKeyFile')
          ]) {
            docker.pullBuildPushImage(
              buildDirectory:   pwd(),
              // use safer way to inject ssh key during docker build
              buildArgs: "--ssh default=\$sshKeyFile --build-arg USER_ID=\$(id -u)",
              registryImageUrl: "${REGISTRY_QA}/${IMAGE_NAME_SPA}",
              tagPrefix:        "${IMAGE_NAME_SPA}:",
              localTagName:     "latest",
              tags: [
                shortSha,
                branchName
              ],
              pullTags: ['main']
            )
          }
        }
      }
    }

    stage('Linting') {
      steps {
        sh """
          docker run --rm \
            -v ${env.WORKSPACE}:/app \
            -v /app/node_modules \
            ${IMAGE_NAME_SPA} \
            npm run lint
        """
      }
    }

    stage('UT') {
      steps {
        script {
          sh """docker run --rm  \
            -v ${env.WORKSPACE}:/app \
            -v /app/node_modules \
            ${IMAGE_NAME_SPA} \
            npm run test:coverage -- --ci
          """

          junit 'output/junit.xml'

          // https://plugins.jenkins.io/clover/
          step([
            $class: 'CloverPublisher',
            cloverReportDir: 'output/coverage',
            cloverReportFileName: 'clover.xml',
            healthyTarget: [
              methodCoverage: 70,
              conditionalCoverage: 70,
              statementCoverage: 70
            ],
            // build will not fail but be set as unhealthy if coverage goes
            // below 60%
            unhealthyTarget: [
              methodCoverage: 60,
              conditionalCoverage: 60,
              statementCoverage: 60
            ],
            // build will fail if coverage goes below 50%
            failingTarget: [
              methodCoverage: 50,
              conditionalCoverage: 50,
              statementCoverage: 50
            ]
          ])
        }
      }
    }

    stage('Build SPA') {
      steps {
        script {
          sh """
            docker run --rm \
              -v ${env.WORKSPACE}:/app \
              -v /app/node_modules \
              ${IMAGE_NAME_SPA}
          """
        }
      }
    }

    stage('Accessibility tests') {
      steps {
        script {
          // the pa11y-ci could have been made available in the node image
          // to avoid installation each time, the build is launched
          sh '''
            sudo npm install -g serve pa11y-ci
            serve -s build > /dev/null 2>&1 &
            pa11y-ci --threshold 5 http://127.0.0.1:3000
          '''
        }
      }
    }

    stage('Build Storybook') {
      steps {
        whenOrSkip(
          params.targetEnv == 'testing'
          && params.buildStorybook == true
        ) {
          script {
            sh """
              docker run --rm \
                -v ${env.WORKSPACE}:/app \
                -v /app/node_modules \
                ${IMAGE_NAME_SPA} \
                sh -c 'npm run storybook:build -- --output-dir build/storybook \
                  && npm run storybook:build-docs -- --output-dir build/storybook-docs'
            """
            buildInfo.storyBookAvailable = true
          }
        }
      }
    }

    stage('Artifacts to S3') {
      steps {
        whenOrSkip(params.targetEnv != 'none') {
          script {
            if (params.targetEnv == 'production') {
              utils.initAws('arn:aws:iam::awsIamId:role/JenkinsSlave')
            }

            sh "aws s3 cp ${env.WORKSPACE}/build ${s3BaseUrl}/${buildBucketPrefix} --recursive --no-progress"
            sh "aws s3 cp ${env.WORKSPACE}/build ${s3BaseUrl}/project1 --recursive --no-progress"

            if (params.targetEnv == 'production') {
              echo 'project SPA packages have been pushed to production bucket.'
              echo '''You can refresh the production indexes with the CD
              production pipeline.'''
              cloudflare.zonePurge(CLOUDFLARE_ZONE_ID_PROD, [prefixes:[
                "${S3_PROD_PUBLIC_URL}/project1/"
              ]])
            } else {
              cloudflare.zonePurge(CLOUDFLARE_ZONE_ID, [prefixes:[
                "${S3_PUBLIC_URL}/${buildBucketPrefix}/"
              ]])

              buildInfo.spaAvailable = true
              publishChecks detailsURL: buildInfo.spaUrl,
                name: 'projectSpaUrl',
                title: 'project SPA url'
            }
            addBuildInfo(buildInfo)
          }
        }
      }
    }
  }

  post {
    always {
      script {
        git.updateConditionalGithubCommitStatus()
        mail.sendConditionalEmail()
      }
    }
  }
}
```

<!-- markdownlint-enable MD013 -->
