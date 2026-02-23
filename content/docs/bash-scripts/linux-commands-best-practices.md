---
title: Linux Commands Best Practices
creationDate: "2023-11-09"
lastUpdated: "2026-02-17"
description: Best practices for using Linux commands in Bash scripts
weight: 20
categories: [Bash]
tags: [linux, bash, scripts, best-practices]
---

- [1. some commands default options to use](#1-some-commands-default-options-to-use)
- [2. Bash and grep regular expressions](#2-bash-and-grep-regular-expressions)

## 1. some commands default options to use

- <https://dougrichardson.us/notes/fail-fast-bash-scripting.html> but set -o nounset is not usable because empty array
  are considered unset
- always use `sed -E`
- avoid using grep -P as it is not supported on alpine, prefer using -E

<!-- markdownlint-capture -->

<!-- markdownlint-disable MD033 -->

## 2. <a name="regularExpressions"></a>Bash and grep regular expressions

<!-- markdownlint-restore -->

- grep regular expression `[A-Za-z]` matches by default accentuated character, if you don't want to match them, use the
  environment variable `LC_ALL=POSIX`,
  - Eg: `LC_ALL=POSIX grep -E -q '^[A-Za-z_0-9:]+$'`
  - I added `export LC_ALL=POSIX` in all my headers, it can be overridden using a subShell
