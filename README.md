# My documents

> **_NOTE:_** **Documentation is best viewed on [https://devlab.top](https://devlab.top/)**

<!-- markdownlint-capture -->

![GitHubLicense](https://img.shields.io/github/license/fchastanet/my-documents?label=license&style=for-the-badge)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![CI/CD](https://github.com/fchastanet/my-documents/actions/workflows/main.yml/badge.svg)](https://github.com/fchastanet/my-documents/actions/workflows/main.yml?query=branch%3Amaster)
[![Project status](https://opensource.box.com/badges/active.svg)](http://opensource.box.com/badges "Project status")
[![DeepSource](https://deepsource.io/gh/fchastanet/my-documents.svg/?label=active+issues&show_trend=true)](https://deepsource.io/gh/fchastanet/my-documents/?ref=repository-badge "DeepSource active issues")
[![DeepSource](https://deepsource.io/gh/fchastanet/my-documents.svg/?label=resolved+issues&show_trend=true)](https://deepsource.io/gh/fchastanet/my-documents/?ref=repository-badge "DeepSource resolved issues")

<!--TOC-->

- [1. Documentation Content](#1-documentation-content)
  - [1.1. Bash scripts](#11-bash-scripts)
  - [1.2. HowTos](#12-howtos)
  - [1.3. Lists](#13-lists)
- [2. Technical Architecture Summary](#2-technical-architecture-summary)
- [3. Reusable Workflow for Dependent Repositories](#3-reusable-workflow-for-dependent-repositories)
  - [3.1. Quick Start](#31-quick-start)
  - [3.2. Full Documentation](#32-full-documentation)

<!--TOC-->

A personal collection of guides and resources on software development, testing, and documentation, organized by topic.

> **_TIP:_** Checkout related projects of this suite
>
> - **[My documents](https://devlab.top/)**
> - [Bash Tools Framework](https://bash-tools-framework.devlab.top/)
> - [Bash Tools](https://bash-tools.devlab.top/)
> - [Bash Dev Env](https://bash-dev-env.devlab.top/)
> - [Bash Compiler](https://bash-compiler.devlab.top/)

## 1. Documentation Content

### 1.1. Bash scripts

- [Basic best practices](https://devlab.top/docs/bash-scripts/basic-best-practices/)
- [Linux best practices](https://devlab.top/docs/bash-scripts/linux-commands-best-practices/)
- [Bats best practices](https://devlab.top/docs/bash-scripts/bats-best-practices/)

### 1.2. HowTos

- [How to write a Jenkinsfile](https://devlab.top/docs/howtos/howto-write-jenkinsfile/)
- [How to write a Dockerfile](https://devlab.top/docs/howtos/howto-write-dockerfile/)
- [How to write a docker-compose.yml file](https://devlab.top/docs/howtos/howto-write-docker-compose/)
- [Saml2Aws](https://devlab.top/docs/howtos/saml2aws/)

### 1.3. Lists

- [Test](https://devlab.top/docs/lists/test/)
- [Web](https://devlab.top/docs/lists/web/)

## 2. Technical Architecture Summary

This section summarizes the orchestrator's technical architecture. For full details, see
[Technical Architecture](https://devlab.top/docs/my-documents/01-technical-architecture/).

- Centralized orchestrator builds and deploys five documentation sites using Hugo and Docsy.
- Sites managed: my-documents, bash-compiler, bash-tools, bash-tools-framework, bash-dev-env.
- Shared base config with per-site YAML overrides, merged via yq.
- GitHub Actions matrix builds all sites in parallel (~60s total).
- GitHub App handles secure deployments; repository_dispatch triggers orchestrator.
- Shared layouts, assets, and archetypes reused across all sites.
- Content structure: each site stores content in `content/docs/`; navigation auto-generated.
- Custom partials for SEO meta tags, minified HTML output, optimized assets.
- Pre-commit hooks and MegaLinter enforce Markdown, YAML, Bash, and spelling standards.
- Local development: Makefile for build/test; Hugo Extended and Go required.
- Automated deployment to GitHub Pages for each site; status tracked via CI.
- Adding sites: checklist-driven process for new repos, configs, and workflow updates.
- Troubleshooting guides for build, deployment, and linting issues.
- Secrets managed via GitHub App and PAT; secret scanning enforced.
- Test all sites after shared changes; document and review before commit.
- Internal links use relative paths; code blocks are language-specified.
- CI/CD: lint, build, and deploy workflows run on master branch.
- Custom dictionaries for Bash terms; auto-sorted and enforced.
- Robust, scalable, and secure multi-site documentation platform.

## 3. Reusable Workflow for Dependent Repositories

The `trigger-docs-reusable.yml` workflow enables dependent repositories to trigger documentation builds in my-documents
without managing secrets or authentication.

### 3.1. Quick Start

Add this to `.github/workflows/trigger-docs.yml` in your dependent repository:

```yaml
name: Trigger Documentation Build

on:
  push:
    branches: [master]
    paths:
      - content/**
      - static/**

jobs:
  trigger-docs:
    uses: |-
      fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    secrets: inherit
```

**That's it!** No secrets configuration needed. The workflow automatically:

- ✅ Uses GitHub App authentication (no PAT tokens required)
- ✅ Triggers centralized build in my-documents
- ✅ Provides detailed build status and links
- ✅ Handles all authentication securely

### 3.2. Full Documentation

For detailed documentation including advanced usage, troubleshooting, and migration guide:

**📖
[Trigger My-Documents Workflow Documentation](https://devlab.top/docs/my-documents/11-trigger-my-documents-workflow/)**

Topics covered:

- Architecture and authentication flow
- Configuration options and input parameters
- Advanced usage examples
- Troubleshooting guide
- Migration from PAT-based approach
- Best practices and FAQ
