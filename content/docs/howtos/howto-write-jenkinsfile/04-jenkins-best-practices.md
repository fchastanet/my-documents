---
title: Jenkins Best Practices
creationDate: "2023-07-01"
lastUpdated: "2026-02-17"
description: Best practices and patterns for Jenkins and Jenkinsfiles
weight: 40
categories: [Jenkins]
tags: [jenkins, jenkinsfile, ci-cd]
---

## 1. Pipeline best practices

[Official Jenkins pipeline best practices](https://www.jenkins.io/doc/book/pipeline/pipeline-best-practices/#general)

Summary:

- Make sure to use Groovy code in Pipelines as glue
- Externalize shell scripts from Jenkins Pipeline
  - for better jenkinsfile readability
  - in order to test the scripts isolated from jenkins
- Avoid complex Groovy code in Pipelines
  - Groovy code **always** executes on controller which means using controller resources(memory and CPU)
    - it is not the case for shell scripts
  - eg1: prefer using **jq** inside shell script instead of groovy JsonSlurper
  - eg2: prefer calling **curl** instead of groovy http request
- Reducing repetition of similar Pipeline steps (eg: one sh step instead of severals)
  - group similar steps together to avoid step creation/destruction overhead
- Avoiding calls to Jenkins.getInstance

## 2. Shared library best practices

[Official Jenkins shared libraries best practices](https://www.jenkins.io/doc/book/pipeline/pipeline-best-practices/#using-shared-libraries)

Summary:

- Do not override built-in Pipeline steps
- Avoiding large global variable declaration files
- Avoiding very large shared libraries

And:

- import jenkins library using a tag
  - like in docker build, npm package with package-lock.json or python pip lock, it's advised to target a given version
    of the library
    - because some changes could break
- The missing part: we miss on this library unit tests
  - but each pipeline is a kind of integration test
- Because a pipeline can be
  [resumed](https://www.jenkins.io/doc/book/pipeline/pipeline-best-practices/#avoiding-notserializableexception), your
  library's classes should implement Serializable class and the following attribute has to be provided:

```groovy
private static final long serialVersionUID = 1L
```
