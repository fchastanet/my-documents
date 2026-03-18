---
title: Prek an alternative to pre-commit
description: Comprehensive documentation on how to use Prek, a replacement for pre-commit, with a focus on speed and ease of use
creationDate: '2026-02-22'
lastUpdated: '2026-02-22'
version: '1.0'
categories: [Tooling]
tags: [Prek, pre-commit, tooling]
---

Prek is a modern alternative to pre-commit, designed to be faster and easier to use. It provides a streamlined
experience for managing and running pre-commit hooks, with a focus on performance and simplicity.

## 1. Key Features of Prek

- **Speed**: Prek is optimized for speed, allowing you to run hooks quickly and efficiently.
- **Ease of Use**: With a simple configuration and intuitive commands, Prek makes it easy to set up and manage your
  pre-commit hooks.
- **Compatibility**: Prek is compatible with existing pre-commit configurations, making it easy to switch without losing
  your current setup.
- **Extensibility**: Prek supports custom hooks and integrations, allowing you to tailor it to your specific needs.

## 2. Getting Started with Prek

```bash
# Install Prek
pip install prek
# Initialize Prek in your repository
prek init
# Add hooks to your configuration
prek add <hook-name>
# Run Prek to execute hooks
prek run
```

## 3. Install Prek on a repository that was using pre-commit

```bash
# Install Prek
pip install prek
# Install prek hooks, it will overwrite your existing pre-commit configuration with a Prek configuration
prek install --install-hooks
# by default prek will keep existing pre-commit hooks, to remove them you can use the --overwrite flag
prek install --install-hooks -t pre-push -t pre-commit --overwrite
# Run Prek to execute hooks
prek run
```

## 4. Performance benchmarks

[Happier Developers, Faster Teams: Why Prek Beats Pre-commit](https://aiechoes.substack.com/p/happier-developers-faster-teams-why)
[Backup page of the above article](https://my-documents.fchastanet.com/docs/backups/happier-developers-faster-teams-why-prek-beats-pre-commit/)
