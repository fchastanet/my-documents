---
title: How to Write Docker Compose Files
description: Guide to writing and organizing Docker Compose files
pageInfo: |-
  Best practices for writing Docker Compose files, including platform targeting and service health checks.
weight: 30
categories: [Docker]
tags: [docker, docker-compose, best-practices]
previewImage: assets/howto-write-docker-compose.webp
date: '2023-07-01T08:00:00+02:00'
lastmod: '2026-05-15T22:23:28+02:00'
version: '1.2'
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

## 2. Wait for a service to be healthy before starting another one

If you have a service that depends on another one, it is important to wait for the dependent service to be healthy
before starting the dependent one. This can be achieved using the `depends_on` option with the
`condition: service_healthy` condition.

Here is an example where `serviceB` depends on `serviceA` being healthy before it starts:

```yaml
services:
  serviceA:
    # ...
    healthcheck:
      test: [CMD, curl, -f, http://localhost:8080/health]
      interval: 30s
      timeout: 10s
      retries: 3
  serviceB:
    # ...
    depends_on:
      serviceA:
        condition: service_healthy
```

In this example, `api` service will wait for the `db` service to be healthy before it starts. The health check for the
`db` service is defined to check if the MySQL server is responding to ping requests.

```yaml
version: '2.1'
services:
  api:
    build: .
    container_name: api
    ports:
      - 8080:8080
    depends_on:
      db:
        condition: service_healthy
  db:
    container_name: db
    image: mysql
    ports:
      - '3306'
    environment:
      MYSQL_ALLOW_EMPTY_PASSWORD: yes
      MYSQL_USER: user
      MYSQL_PASSWORD: password
      MYSQL_DATABASE: database
    healthcheck:
      test: [CMD, mysqladmin, ping, -h, localhost]
      timeout: 20s
      retries: 10
```
