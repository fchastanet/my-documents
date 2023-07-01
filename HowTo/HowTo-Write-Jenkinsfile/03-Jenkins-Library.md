# Jenkins shared library

- [1. What is a jenkins shared library ?](#1-what-is-a-jenkins-shared-library-)
- [2. Loading libraries dynamically](#2-loading-libraries-dynamically)
- [3. jenkins library directory structure](#3-jenkins-library-directory-structure)
- [4. Jenkins library](#4-jenkins-library)
- [5. Jenkins library structure](#5-jenkins-library-structure)
- [6. external resource usage](#6-external-resource-usage)

## 1. What is a jenkins shared library ?

> As Pipeline is adopted for more and more projects in an organization, common
> patterns are likely to emerge. Oftentimes it is useful to share parts of
> Pipelines between various projects to reduce redundancies and keep code "DRY"

for more information check [pipeline shared libraries](https://www.jenkins.io/doc/book/pipeline/shared-libraries/)

## 2. Loading libraries dynamically

As of version 2.7 of the _Pipeline: Shared Groovy Libraries_ plugin, there is a
new option for loading (non-implicit) libraries in a script: a `library` step
that loads a library _dynamically_, at any time during the build.

If you are only interested in using global variables/functions (from the
`vars/` directory), the syntax is quite simple:

```groovy
library 'my-shared-library'
```

Thereafter, any global variables from that library will be accessible to the script.

## 3. jenkins library directory structure

The directory structure of a Shared Library repository is as follows:

```bash
(root)
+- src        # Groovy source files
|   +- org
|       +- foo
|           +- Bar.groovy  # for org.foo.Bar class
|
+- vars       # The vars directory hosts script 
              # files that are exposed as a variable in Pipelines
|   +- foo.groovy          # for global 'foo' variable 
|   +- foo.txt             # help for 'foo' variable 
|
+- resources  # resource files (external libraries only) 
|   +- org 
|      +- foo 
|         +- bar.json      # static helper data for org.foo.Bar
```

## 4. Jenkins library

remember that jenkins library code is executed on master node

if you want to execute code on the node, you need to use jenkinsExecutor

usage of jenkins executor

```groovy
String credentialsId = 'babee6c1-14fe-4d90-9da0-ffa7068c69af'
def lib = library(
    identifier: 'jenkins_library@v1.0',
    retriever: modernSCM([
        $class: 'GitSCMSource',
        remote: 'git@github.com:fchastanet/jenkins_library.git',
        credentialsId: credentialsId
    ])
)
// this is the jenkinsExecutor instance
def docker = lib.fchastanet.Docker.new(this) 
```

Then in the library, it is used like this:

```groovy
def status = this.jenkinsExecutor.sh(
  script: "docker pull ${cacheTag}", returnStatus: true
)
```

## 5. Jenkins library structure

I remarked that a lot of code was duplicated between all my Jenkinsfiles so I
created this library [https://github.com/fchastanet/jenkins_library](https://github.com/fchastanet/jenkins_library)

```bash
(root)
+- doc    # markdown files automatically generated 
          # from groovy files by generateDoc.sh
+- src    # Groovy source files
|   +- fchastanet
|       +- Cloudflare.groovy     # zonePurge
|       +- Docker.groovy         # getTagCompatibleFromBranch 
                                 # pullBuildPushImage, ...
|       +- Git.groovy            # getRepoURL, getCommitSha, 
                                 # getLastPusherEmail, 
                                 # updateConditionalGithubCommitStatus
|       +- Kubernetes.groovy     # deployHelmChart, ...
|       +- Lint.groovy           # dockerLint, 
                                 # transform lighthouse report 
                                 # to Warnings NG issues format
|       +- Mail.groovy           # sendTeamsNotification,
                                 # sendConditionalEmail, ...
|       +- Utils.groovy          # deepMerge, isCollectionOrArray,
                                 # deleteDirAsRoot, 
                                 # initAws (could be moved to Aws class)
+- vars   # The vars directory hosts script files that 
          # are exposed as a variable in Pipelines
|   +- dockerPullBuildPush.groovy # 
|   +- whenOrSkip.groovy          #
```

## 6. external resource usage

If you need you check out how I used this repository <https://github.com/fchastanet/jenkins_library_resources>
in jenkins_library (Linter) that hosts some resources to parse result files.
