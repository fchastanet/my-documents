# Annotated Jenkinsfile - jenkins library - reusable pipeline generation

## introduction

In jenkins library you can create your own directive that allows to generate
jenkinsfile code. Here we will use this feature to generate a complete
Jenkinsfile.

## Annotated Jenkinsfile

```groovy
library identifier: 'jenkins_library@v1.0',
  retriever: modernSCM([
      $class: 'GitSCMSource',
      remote: 'git@github.com:fchastanet/jenkins-library.git',
      credentialsId: 'jenkinsCredentialsId'
  ])

djangoApiPipeline repoUrl: 'git@github.com:fchastanet/django_api_project.git',
                  imageName: 'django_api'
```

## Annotated library custom directive

In the jenkins library just add a file named `vars/djangoApiPipeline.groovy`
with the following content

```groovy
#!/usr/bin/env groovy

def call(Map args) {
  // content of your pipeline
}
```

## Annotated library custom directive djangoApiPipeline.groovy

```groovy
#!/usr/bin/env groovy

def call(Map args) {

  def gitUtil = new Git(this)
  def mailUtil = new Mail(this)
  def dockerUtil = new Docker(this)
  def kubernetesUtil = new Kubernetes(this)
  def testUtil = new Tests(this)

  String workerLabelNonProd = args?.workerLabelNonProd ?: 'eks-nonprod'
  String workerLabelProd = args?.workerLabelProd ?: 'docker-ubuntu-prod-eks'
  String awsRegionNonProd = workerLabelNonProd == 'eks-nonprod' ? 'us-east-1' : 'eu-west-1'
  String awsRegionProd = 'eu-central-1'
  String regionName = params.targetEnv == 'prod' ? awsRegionProd : awsRegionNonProd
  String teamsEmail = args?.teamsEmail ?: 'teamsChannel.onmicrosoft.com@amer.teams.ms'
  String helmDirectory = args?.helmDirectory ?: './helm'
  Boolean sendCortexMetrics = args?.sendCortexMetrics ?: false
  Boolean skipTests = args?.skipTests ?: false
  List environments = args?.environments ?: ['none', 'qa', 'prod']
  Short skipBuild = 0

  pipeline {
    agent {
      node {
        label params.targetEnv == 'prod' ? workerLabelProd : workerLabelNonProd
      }
    }

    parameters {
      gitParameter branchFilter: 'origin/(.*)',
                    defaultValue: 'main',
                    quickFilterEnabled: true,
                    sortMode: 'ASCENDING_SMART',
                    name: 'BRANCH',
                    type: 'PT_BRANCH'

      choice (
        name: 'targetEnv',
        choices: environments,
        description: 'Where it should be deployed to? (Default: none - No deploy)'
      )

      string (
        name: 'instance',
        defaultValue: '1',
        description: '''The instance ID to define which QA instance it should
        be deployed to (Will only apply if targetEnv is qa). Default is 1 for
        CK and 01 for Darwin'''
      )

      booleanParam(
        name: 'suspendCron',
        defaultValue: true,
        description: 'Suspend cron jobs scheduling'
      )

      choice (
        name: 'upStreamImage',
        choices: ['latest', 'beta'],
        description: '''Select beta to check if your build works with the
        future version of the upstream image'''
      )
    }

    stages {
      stage('Checkout from SCM') {
        steps {
          script {
            echo "Checking out from origin/${BRANCH} branch"
            gitUtil.branchCheckout(
              '',
              'babee6c1-14fe-4d90-9da0-ffa7068c69af',
              args.repoUrl,
              '${BRANCH}'
            )
            wrap([$class: 'BuildUser']) {
              def String displayName = "#${currentBuild.number}_${BRANCH}_${BUILD_USER}_${targetEnv}"

              if (params.targetEnv == 'qa' || params.targetEnv == 'qe') {
                displayName = "${displayName}_${instance}"
              }

              currentBuild.displayName = displayName
            }

            env.imageName = env.BUILD_TAG.toLowerCase()
            env.buildDirectory = args?.buildDirectory ?
              args.buildDirectory + "/" : ""
            env.runCoverage = args?.runCoverage
            env.shortSha = gitUtil.getShortCommitSha(env.GIT_BRANCH)
            skipBuild = dockerUtil.checkImage(args.imageName, shortSha)
          }
        }
      }

      stage('Build') {
        when {
          expression { return skipBuild != 0 }
        }
        steps {
          script {
            String registryUrl = 'dockerRegistryId.dkr.ecr.' +
              awsRegionNonProd + '.amazonaws.com'
            String buildDirectory = args?.buildDirectory ?: pwd()

            if (params.targetEnv == "prod") {
              registryUrl = 'dockerRegistryId.dkr.ecr.' + awsRegionProd + '.amazonaws.com'
            }

            dockerUtil.pullBuildImage(
              registryImageUrl: "${registryUrl}/${args.imageName}",
              pullTags: [
                "${params.targetEnv}"
              ],
              buildDirectory: "${buildDirectory}",
              buildArgs: "--build-arg UPSTREAM_VERSION=${params.upStreamImage}",
              tagPrefix: "${env.imageName}:",
              tags: [
                "${env.shortSha}"
              ]
            )
          }
        }
      }

      stage('Test') {
        when {
          expression { return skipBuild != 0 && skipTests == false }
        }
        steps {
          script {
            testUtil.execTests(args.imageName)
          }
        }
      }
      stage('Push') {
        when {
          expression { return params.targetEnv != 'none' }
        }
        steps {
          script {
            //pipeline execution starting time for CD part
            Map argsMap = [:]

            if (params.targetEnv == "prod") {
              registryUrl = 'registryIdProd.dkr.ecr.' +
                awsRegionProd + '.amazonaws.com'
            } else {
              registryUrl = 'registryIdNonProd.dkr.ecr.' +
                awsRegionNonProd + '.amazonaws.com'
            }

            argsMap = [
              registryImageUrl: "${registryUrl}/${args.imageName}",
              pullTags: [
                "${env.shortSha}",
              ],
              tagPrefix: "${registryUrl}/${args.imageName}:",
              localTagName: "${env.shortSha}",
              tags: [
                "${params.targetEnv}"
              ]
            ]

            if (skipBuild == 0) {
              dockerUtil.promoteTag(argsMap)
            } else {
              argsMap.remove("pullTags")
              argsMap.put("tagPrefix", "${env.imageName}:")
              argsMap.put("tags", ["${env.shortSha}","${params.targetEnv}"])
              dockerUtil.tagPushImage(argsMap)
            }
          }
        }
      }
      stage("Deploy to Kubernetes") {
        when {
          expression { return params.targetEnv != 'none' }
        }
        steps {
          script {
            if (params.targetEnv == 'prod') {
              // not sure it is a good practice as it forces the operator to
              // wait for build to reach this stage
              timeout(time: 300, unit: "SECONDS") {
                input(
                  message: """Do you want go ahead with ${env.shortSha}
                  image tag for prod helm deploy?""",
                  ok: 'Yes'
                )
              }
            }
            CHART_NAME = (args.imageName).contains("_") ?
              (args.imageName).replaceAll("_", "-") :
              (args.imageName)
            if (params.targetEnv == 'qa' || params.targetEnv == 'qe') {
              helmValueFilePath = "${helmDirectory}" +
                "/value_files/values-" + params.targetEnv +
                params.instance + ".yaml"
              NAMESPACE = "${CHART_NAME}-" + params.targetEnv + params.instance
            } else {
              helmValueFilePath = "${helmDirectory}" +
                "/value_files/values-" + params.targetEnv + ".yaml"
              NAMESPACE = "${CHART_NAME}-" + params.targetEnv
            }
            ingressUrl = kubernetesUtil.getIngressUrl(helmValueFilePath)
            echo "Deploying into k8s.."
            echo "Helm release: ${CHART_NAME}"
            echo "Target env: ${params.targetEnv}"
            echo "Url: ${ingressUrl}"
            echo "K8s namespace: ${NAMESPACE}"
            kubernetesUtil.deployHelmChart(
              chartName: CHART_NAME,
              nameSpace: NAMESPACE,
              imageTag: "${env.shortSha}",
              helmDirectory: "${helmDirectory}",
              helmValueFilePath: helmValueFilePath
            )
          }
        }
      }
    }
    post {
      always {
        script {
          gitUtil.updateGithubCommitStatus("${currentBuild.currentResult}", "${env.WORKSPACE}")
          mailUtil.sendConditionalEmail()
          if (params.targetEnv == 'prod') {
              mailUtil.sendTeamsNotification(teamsEmail)
          }
        }
      }
    }
  }
}
```

## Final thoughts about this technique

This technique is really useful when you have a lot of similar projects reusing
over and over the same pipeline. It allows:

- code reuse
- avoid duplicated code
- easier maintenance

However it has the following drawbacks:

- some projects using this generic pipeline could have specific needs
  - eg 1: not the same way to run unit tests, to overcome that issue the method
    `testUtil.execTests` is used allowing to run a specific sh file if it exists
  - eg 2: more complex way to launch docker environment
  - ...
- **be careful**, when you upgrade this jenkinsfile as all the projects using it
  will be upgraded at once
  - it could be seen as an advantage, but it is also a big risk as it could
    impact all the prod environment at once
  - to overcome that issue I suggest to use library versioning when using the
    jenkins library in your project pipeline Eg: check
    [Annotated Jenkinsfile](#annotated-jenkinsfile) `@v1.0` when cloning library
    project
- I highly suggest to use a unit test framework of the library to avoid at most
  bad surprises

In conclusion, I'm still not sure it is a best practice to generate pipelines
like this.
