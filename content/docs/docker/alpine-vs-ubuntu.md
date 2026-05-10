---
title: 'Alpine vs Ubuntu Image: Performance Comparison for Docker Builds'
description: A detailed comparison between Alpine and Ubuntu Docker images, focusing on performance differences in build times and test execution.
weight: 20
categories:
  - Docker
tags:
  - docker
  - alpine
  - ubuntu
  - performance
  - optimization
date: 2025-03-12T08:00:00+01:00
lastmod: 2026-03-21T08:00:00+01:00
version: '1.0'
linkTitle: 'Alpine vs Ubuntu Image: Performance Comparison for Docker Builds'
---

When I was working on a UI project I remarked that unit tests(Jest) were running really slowly on our CI pipeline
(Jenkins). On my local machine, the tests were running in about **1 minute**, but on Jenkins, it was taking around **10
minutes**.

I was wondering why ?

I tested several Jest configurations and ended up adding these parameters `--runInBand` and `--ci`. It made the build
not too slow but still it takes ~7 minutes to run on Jenkins.

## 1. Alpine vs Ubuntu Docker Image

{{< img src="assets/Alpine-vs-Ubuntu.png" width="400" alt="Alpine vs Ubuntu Docker Image" >}}

After checking several forums, I decided to migrate to an Ubuntu-based image. The slowness could be because Alpine uses
musl instead of glibc (used by Ubuntu) as C standard library. Note that the musl library is not always slower than
glibc, but musl is designed to be lightweight.

Here are the results for my specific case. I tested npm install/ci/build/test on my local machine using different Docker
images. | Distribution | Node Version | npm ci/install time | Jest time |

Below is a detailed comparison table of different Node.js Docker images (Ubuntu vs Alpine) for key performance metrics:

<!-- markdownlint-disable MD013 MD033 -->

| Distribution                  | Image<br>Size | Memory usage<br>React watch mode | npm ci<br>duration | npm install<br>duration | npm run build<br>duration | jest<br>duration |
| ----------------------------- | ------------- | -------------------------------- | ------------------ | ----------------------- | ------------------------- | ---------------- |
| Ubuntu node:20.9.0            | 924MB         | 1.54GB                           | **02:53**          | 00:13                   | 00:40                     | 00:47            |
| Ubuntu node:23                | 905MB         | 1.54GB                           | 01:31              | 00:25                   | 00:31                     | 00:31            |
| Alpine node:20.9.0-alpine3.18 | 883MB         | 1.37GB                           | **02:10**          | **01:56**               | **02:01**                 | **01:00**        |
| Alpine node:23-alpine3.20     | 902MB         | 1.37GB                           | 01:56              | 00:33                   | **01:28**                 | 00:33            |

<!-- markdownlint-restore -->

Please note that npm ci/install time is highly dependent on the network, and the results are quite similar. More tests
would be required to have a better overview of the performance. We could also compare with Yarn (I noticed on some
personal projects that Yarn is faster than npm).

The image size is quite similar, practically identical between Ubuntu node:23 and Alpine node:23. So, the argument of
image size is not always a good comparison point to choose between Alpine and Ubuntu.

Where we can see a real difference is in the build time, where Ubuntu is clearly the winner. Also, upgrading from **Node
20** to **Node 23** shows a noticeable performance boost. We went from ~1 minute to ~30 seconds to run Jest on Alpine,
and a boost also occurs for Ubuntu..

Node 23 makes following warning disappear:

<!-- markdownlint-disable MD013 -->

`(node:9) MaxListenersExceededWarning: Possible EventEmitter memory leak detected. 11 close listeners added to [TLSSocket].Use emitter.setMaxListeners() to increase limit`

<!-- markdownlint-restore -->

Finally, here is the difference between the pipeline using Ubuntu or Alpine: OK, test and build are still running quite
slowly on Jenkins, probably due to the machine used and maybe version of docker used. But it takes about 4 minutes less
to test and build Storybook using the Ubuntu-based image. ![alt text](image.png)

As a conclusion, ubuntu is not always the winner, and the choice between Alpine and Ubuntu should be part of our
performance tests. Alpine is often considered more secure due to its smaller attack surface, but on the other hand,
Ubuntu has a larger community and more resources dedicated to security and patching.

Also, have a look to
[some best practices you should apply when creating a Dockerfile](https://devlab.top/docs/howtos/howto-write-dockerfile/).

Do not hesitate to use my new
[AI Docker Skill](https://github.com/fchastanet/copilot-prompts/blob/master/skills/fc-optimize-dockerfile/SKILL.md) to
get personalized recommendations for optimizing your Docker images and improving build performance using an AI Copilot
Agent.
