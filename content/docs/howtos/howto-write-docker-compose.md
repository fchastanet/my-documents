---
title: How to Write Docker Compose Files
description: Guide to writing and organizing Docker Compose files
weight: 30
categories: [Docker]
tags: [docker, docker-compose, best-practices]
date: '2023-07-01T08:00:00+02:00'
lastmod: '2026-02-17T08:00:00+01:00'
version: '1.0'
---

## 1. platform

as not everyone is using the same environment (some are using MacOS for example which is targeting arm64 instead of
amd64), it is advised to add this option to target the right architecture

**docker-compose platform**:

```yaml
services:
  serviceName:
    platform: linux/x86_64
  # ...
```
