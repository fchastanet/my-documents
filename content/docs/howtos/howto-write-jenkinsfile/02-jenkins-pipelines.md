---
title: Jenkins Pipelines
description: Declarative and scripted pipeline syntax
weight: 20
categories: [Jenkins]
tags: [jenkins, jenkinsfile, ci-cd]
---

- [1. What is a pipeline ?](#1-what-is-a-pipeline-)
- [2. Pipeline creation via UI](#2-pipeline-creation-via-ui)
- [3. Groovy](#3-groovy)
- [4. Difference between scripted pipeline (freestyle) and declarative pipeline syntax](#4-difference-between-scripted-pipeline-freestyle-and-declarative-pipeline-syntax)
- [5. Declarative pipeline example](#5-declarative-pipeline-example)
- [6. Scripted pipeline example](#6-scripted-pipeline-example)
- [7. Why Pipeline?](#7-why-pipeline)

## 1. What is a pipeline ?

[https://www.jenkins.io/doc/book/pipeline/](https://www.jenkins.io/doc/book/pipeline/)

> Jenkins Pipeline (or simply "Pipeline" with a capital "P") is a suite of plugins which supports implementing and
> integrating _continuous delivery pipelines_ into Jenkins.
>
> A _continuous delivery (CD) pipeline_ is an automated expression of your process for getting software from version
> control right through to your users and customers. Every change to your software (committed in source control) goes
> through a complex process on its way to being released. This process involves building the software in a reliable and
> repeatable manner, as well as progressing the built software (called a "build") through multiple stages of testing and
> deployment.
>
> Pipeline provides an extensible set of tools for modeling simple-to-complex delivery pipelines "as code" via the
> [Pipeline domain-specific language (DSL) syntax](https://www.jenkins.io/doc/book/pipeline/syntax).
> [View footnote 1](https://www.jenkins.io/doc/book/pipeline/#_footnotedef_1 "View footnote.")
>
> The definition of a Jenkins Pipeline is written into a text file (called a
> [`Jenkinsfile`](https://www.jenkins.io/doc/book/pipeline/jenkinsfile)) which in turn can be committed to a project’s
> source control repository.
> [View footnote 2](https://www.jenkins.io/doc/book/pipeline/#_footnotedef_2 "View footnote.") This is the foundation of
> "Pipeline-as-code"; treating the CD pipeline a part of the application to be versioned and reviewed like any other
> code.

## 2. Pipeline creation via UI

it's not recommended but it's possible to create a pipeline via the UI.

There are several drawbacks:

- no code revision
- difficult to read, understand

## 3. Groovy

Scripted and declarative pipelines are using groovy language.

Checkout [https://www.guru99.com/groovy-tutorial.html](https://www.guru99.com/groovy-tutorial.html) to have a quick
overview of this derived language check [Wikipedia](https://en.wikipedia.org/wiki/Apache_Groovy)

## 4. Difference between scripted pipeline (freestyle) and declarative pipeline syntax

What are the main differences ? Here are some of the most important things you should know:

- Basically, declarative and scripted pipelines differ in terms of the programmatic approach. One uses a declarative
  programming model and the second uses an imperative programming mode.
- Declarative pipelines break down stages into multiple steps, while in scripted pipelines there is no need for this.
  Example below

Declarative and Scripted Pipelines are constructed fundamentally differently. **Declarative Pipeline is a more recent
feature of Jenkins Pipeline** which:

- provides richer syntactical features over Scripted Pipeline syntax, and
- is designed to make writing and reading Pipeline code easier.
- By default automatically checkout stage

Many of the individual syntactical components (or "steps") written into a `Jenkinsfile`, however, are common to both
Declarative and Scripted Pipeline. Read more about how these two types of syntax differ in
[Pipeline concepts](https://www.jenkins.io/doc/book/pipeline/#pipeline-concepts) and
[Pipeline syntax overview](https://www.jenkins.io/doc/book/pipeline/#pipeline-syntax-overview).

## 5. Declarative pipeline example

[Pipeline syntax documentation](https://www.jenkins.io/doc/book/pipeline/syntax/)

```groovy
 pipeline {
   agent {
     // executed on an executor with the label 'some-label'
     // or 'docker', the label normally specifies:
     // - the size of the machine to use
     //   (eg.: Docker-C5XLarge used for build that needs a powerful machine)
     // - the features you want in your machine
     //   (eg.: docker-base-ubuntu an image with docker command available)
     label "some-label"
   }

   stages {
     stage("foo") {
       steps {
         // variable assignment and Complex global
         // variables (with properties or methods)
         // can only be done in a script block
         script {
           foo = docker.image('ubuntu')
           env.bar = "${foo.imageName()}"
           echo "foo: ${foo.imageName()}"
         }
       }
     }
     stage("bar") {
       steps{
         echo "bar: ${env.bar}"
         echo "foo: ${foo.imageName()}"
       }
     }
   }
 }
```

## 6. Scripted pipeline example

Scripted pipelines permit a developer to inject code, while the declarative Jenkins pipeline doesn’t. **should be
avoided actually, try to use jenkins library instead**

```groovy
node {

  git url: 'https://github.com/jfrogdev/project-examples.git'

  // Get Artifactory server instance, defined in the Artifactory Plugin
  // administration page.
  def server = Artifactory.server "SERVER_ID"

  // Read the upload spec and upload files to Artifactory.
  def downloadSpec =
       '''{
       "files": [
         {
            "pattern": "libs-snapshot-local/*.zip",
            "target": "dependencies/",
            "props": "p1=v1;p2=v2"
         }
       ]
   }'''

  def buildInfo1 = server.download spec: downloadSpec

  // Read the upload spec which was downloaded from github.
  def uploadSpec =
     '''{
     "files": [
       {
          "pattern": "resources/Kermit.*",
          "target": "libs-snapshot-local",
          "props": "p1=v1;p2=v2"
       },
       {
          "pattern": "resources/Frogger.*",
          "target": "libs-snapshot-local"
       }
      ]
   }'''


  // Upload to Artifactory.
  def buildInfo2 = server.upload spec: uploadSpec

  // Merge the upload and download build-info objects.
  buildInfo1.append buildInfo2

  // Publish the build to Artifactory
  server.publishBuildInfo buildInfo1
}
```

## 7. Why Pipeline?

Jenkins is, fundamentally, an automation engine which supports a number of automation patterns. Pipeline adds a powerful
set of automation tools onto Jenkins, supporting use cases that span from simple continuous integration to comprehensive
CD pipelines. By modeling a series of related tasks, users can take advantage of the many features of Pipeline:

- **Code**: Pipelines are implemented in code and typically checked into source control, giving teams the ability to
  edit, review, and iterate upon their delivery pipeline.
- **Durable**: Pipelines can survive both planned and unplanned restarts of the Jenkins controller.
- **Pausable**: Pipelines can optionally stop and wait for human input or approval before continuing the Pipeline run.
- **Versatile**: Pipelines support complex real-world CD requirements, including the ability to fork/join, loop, and
  perform work in parallel.
- **Extensible**: The Pipeline plugin supports custom extensions to its DSL
  [see jenkins doc](https://www.jenkins.io/doc/book/pipeline/#_footnotedef_1) and multiple options for integration with
  other plugins.

While Jenkins has always allowed rudimentary forms of chaining Freestyle Jobs together to perform sequential tasks,
[see jenkins doc](https://www.jenkins.io/doc/book/pipeline/#_footnotedef_4) Pipeline makes this concept a first-class
citizen in Jenkins.

More information on [Official jenkins documentation - Pipeline](https://www.jenkins.io/doc/book/pipeline/)
