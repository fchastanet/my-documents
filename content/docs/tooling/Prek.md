---
title: Prek an alternative to pre-commit
description: Comprehensive documentation on how to use Prek, a replacement for pre-commit, with a focus on speed and ease of use
version: '1.0'
categories: [Tooling]
tags: [Prek, pre-commit, tooling]
date: '2026-02-22T08:00:00+01:00'
lastmod: '2026-02-22T08:00:00+01:00'
---

Prek is a modern alternative to pre-commit, designed to be faster and easier to use. It provides a streamlined
experience for managing and running pre-commit hooks, with a focus on performance and simplicity.

From the author:

> pre-commit is a framework to run hooks written in many languages, and it manages the language toolchain and
> dependencies for running the hooks. prek is a reimagined version of pre-commit, built in Rust. It is designed to be a
> faster, dependency-free and drop-in alternative for it, while also providing some additional long-requested features.

## 1. Key Features of Prek

- **Speed**: Prek is optimized for speed, allowing you to run hooks quickly and efficiently.
- **Ease of Use**: With a simple configuration and intuitive commands, Prek makes it easy to set up and manage your
  pre-commit hooks.
- **Compatibility**: Prek is compatible with existing pre-commit configurations, making it easy to switch without losing
  your current setup.
- **Extensibility**: Prek supports custom hooks and integrations, allowing you to tailor it to your specific needs.

## 2. Getting Started with Prek

### 2.1. Install Prek

```bash
# Install Prek
pip install prek
```

### 2.2. Initialize Prek in Your Repository

```bash
# Initialize Prek in your repository
prek sample-config -f .pre-commit-config.yaml --format yaml
# Run Prek to execute pre-commit and pre-push hooks
prek install --install-hooks -t pre-push -t pre-commit --overwrite
```

### 2.3. Initialize Prek on a repository that was using pre-commit

```bash
# Install prek hooks, it will overwrite your existing pre-commit configuration with a Prek configuration
prek install --install-hooks
# by default prek will keep existing pre-commit hooks, to remove them you can use the --overwrite flag
prek install --install-hooks -t pre-push -t pre-commit --overwrite
```

### 2.4. Run Prek

```bash
# Run Prek to execute pre-commit and pre-push hooks on all files (staged or not)
prek run -a
```

## 3. Performance benchmarks

[Happier Developers, Faster Teams: Why Prek Beats Pre-commit](https://aiechoes.substack.com/p/happier-developers-faster-teams-why)
[Backup page of the above article](https://devlab.top/docs/backups/happier-developers-faster-teams-why-prek-beats-pre-commit/)

## 4. Conclusion

Prek is a powerful and efficient alternative to pre-commit, offering improved performance and a more user-friendly
experience. Whether you're looking to speed up your pre-commit hooks or simplify your workflow, Prek is a great choice
for modern development teams. Give it a try and see the difference it can make in your development process!

[Prek GitHub Repository](https://github.com/j178/prek)
