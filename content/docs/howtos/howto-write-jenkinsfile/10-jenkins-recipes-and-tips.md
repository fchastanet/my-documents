---
title: Jenkins Recipes and Tips
creationDate: "2023-07-01"
lastUpdated: "2026-02-17"
description: Useful recipes and tips for Jenkins and Jenkinsfiles
weight: 100
categories: [Jenkins]
tags: [jenkins, jenkinsfile, ci-cd]
---

## 1. Jenkins snippet generator

Use jenkins snippet generator by adding `/pipeline-syntax/` to your jenkins pipeline. to allow you to generate jenkins
pipeline code easily with inline doc. It also list the available variables.

![jenkins snippet generator](images/snippetGenerator.png)

## 2. Declarative pipeline allows you to restart a build from a given stage

![restart from stage](images/restartFromStage.png)

## 3. Replay a pipeline

Replaying a pipeline allows you to update your jenkinsfile before replaying the pipeline, easier debugging !
![replay a pipeline](images/replayPipeline.png)

## 4. VS code Jenkinsfile validation

Please follow this documentation
[enable jenkins pipeline linter in vscode](https://github.com/fchastanet/coding_dojo_jenkins/blob/master/Exercise03%20-%20Full%20pipeline.md#step-01b---enable-jenkins-pipeline-linter-in-vscode)

## 5. How to chain pipelines ?

Simply use the `build` directive followed by the name of the build to launch

```groovy
build 'OtherBuild'
```

## 6. Viewing pipelines hierarchy

The [downstream-buildview plugin](https://plugins.jenkins.io/downstream-buildview/) allows to view the full chain of
dependent builds.

![Jenkins Downstream Build Pipeline Visualization](https://raw.githubusercontent.com/jenkins-infra/plugins-wiki-docs/master/downstream-buildview/docs/images/downstream-buildview_screen1.JPG)
