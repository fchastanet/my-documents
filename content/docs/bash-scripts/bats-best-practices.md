---
title: Bats Testing Framework
description: Best practices for testing Bash scripts with Bats framework
pageInfo: |-
  This document provides best practices for testing Bash scripts using the Bats testing framework. Following these
  practices will help you write more effective and maintainable tests for your Bash scripts.
weight: 30
categories:
  - testing
tags:
  - bash
  - bats
  - unit-test
  - scripts
  - best-practices
fmContentType: content
linkTitle: Bats Testing Framework
previewImage: assets/bats-best-practices.webp
date: '2023-11-09T08:00:00+01:00'
lastmod: '2026-05-11T23:28:39+02:00'
version: '1.2'
---

## 1. use of default temp directory created by bats

Instead of creating yourself your temp directory, you can use the special variable `BATS_TEST_TMPDIR`, this directory is
automatically destroyed at the end of the test except if the option `--no-tempdir-cleanup` is provided to bats command.

**Exception**: if you are testing bash traps, you would need to create your own directories to avoid unexpected errors.

## 2. avoid boilerplate code

using this include, includes most of the features needed when using bats

```bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
```

It sets those bash features:

- set -o errexit
- set -o pipefail

It imports several common files like some additional bats features.

And makes several variables available:

- BASH_TOOLS_ROOT_DIR
- vendorDir
- srcDir
- FRAMEWORK_ROOT_DIR (same as BASH_TOOLS_ROOT_DIR but used by some bash framework functions)
- LC_ALL=POSIX see
  [Bash and grep regular expressions best practices](/HowTo/HowTo-Write-Bash-Scripts/10-LinuxCommands-BestPractices.md#regularExpressions)

## 3. Override an environment variable when using bats run

```bash
SUDO="" run Linux::Apt::update
```

## 4. Override a bash framework function

using stub is not possible because it does not support executable with special characters like `::`. So the solution is
just to override the function inside your test function without importing the original function of course. In tearDown
method do not forget to use `unset -f yourFunction`
