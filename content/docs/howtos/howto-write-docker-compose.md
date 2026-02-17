---
title: How to Write Docker Compose Files
description: Guide to writing and organizing Docker Compose files
weight: 30
---

- [1. platform](#1-platform)

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
