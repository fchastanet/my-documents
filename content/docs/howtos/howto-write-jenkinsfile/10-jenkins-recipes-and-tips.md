---
title: Jenkins Recipes and Tips
description: Useful recipes and tips for Jenkins and Jenkinsfiles
weight: 100
categories: [Jenkins]
tags: [jenkins, jenkinsfile, ci-cd]
date: '2023-07-01T08:00:00+02:00'
lastmod: '2026-02-17T08:00:00+01:00'
version: '1.0'
---

## 1. Jenkins snippet generator

Use jenkins snippet generator by adding `/pipeline-syntax/` to your jenkins pipeline. to allow you to generate jenkins
pipeline code easily with inline doc. It also list the available variables.

{{< img src="assets/snippetGenerator.png" alt="jenkins snippet generator" >}}

## 2. Declarative pipeline allows you to restart a build from a given stage

{{< img src="assets/restartFromStage.png" alt="restart from stage" >}}

## 3. Replay a pipeline

Replaying a pipeline allows you to update your jenkinsfile before replaying the pipeline, easier debugging !

{{< img src="assets/replayPipeline.png" alt="replay a pipeline" >}}

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
