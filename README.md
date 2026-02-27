# My documents

<!-- remove -->

> **_NOTE:_** Documentation is best viewed on
> [github-pages](https://fchastanet.github.io/my-documents/)

<!-- endRemove -->

> **_TIP:_** Checkout related projects of this suite
>
> - **[My documents](https://fchastanet.github.io/my-documents/)**
> - [Bash Tools Framework](https://fchastanet.github.io/bash-tools-framework/)
> - [Bash Tools](https://fchastanet.github.io/bash-tools/)
> - [Bash Dev Env](https://fchastanet.github.io/bash-dev-env/)
> - [Bash Compiler](https://fchastanet.github.io/bash-compiler/)

<!-- markdownlint-capture -->

![GitHubLicense](https://img.shields.io/github/license/fchastanet/my-documents?label=license&style=for-the-badge)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![CI/CD](https://github.com/fchastanet/my-documents/actions/workflows/main.yml/badge.svg)](https://github.com/fchastanet/my-documents/actions?query=workflow:%22Pre-commit+run%22+branch:master)
[![Hugo Build & Deploy](https://github.com/fchastanet/my-documents/actions/workflows/hugo-build-deploy.yml/badge.svg)](https://github.com/fchastanet/my-documents/actions?query=workflow:%22Deploy+Hugo%22+branch:master)
[![ProjectStatus](http://opensource.box.com/badges/active.svg)](http://opensource.box.com/badges "Project Status")
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

## 1. Documentation Content

### 1.1. Bash scripts

- [Basic best practices](/docs/bash-scripts/00-basic-best-practices/)
- [Linux best practices](/docs/bash-scripts/10-linux-commands-best-practices/)
- [Bats best practices](/docs/bash-scripts/20-bats-best-practices/)

### 1.2. HowTos

- [How to write a Jenkinsfile](/docs/howtos/howto-write-jenkinsfile/)
- [How to write a Dockerfile](/docs/howtos/howto-write-dockerfile/)
- [How to write a docker-compose.yml file](/docs/howtos/howto-write-docker-compose/)
- [Saml2Aws](/docs/howtos/saml2aws/)

### 1.3. Lists

- [Test](/docs/lists/test/)
- [Web](/docs/lists/web/)

## 2. Technical Architecture Summary

This section summarizes the orchestrator's technical architecture. For full details, see [Technical Architecture](/content/docs/my-documents/technical-architecture.md).

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
---
name: Trigger Documentation Build

on:
  push:
    branches: [master]
    paths:
      - 'content/**'
      - 'static/**'

jobs:
  trigger-docs:
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    secrets: inherit
```

**That's it!** No secrets configuration needed. The workflow automatically:

- ✅ Uses GitHub App authentication (no PAT tokens required)
- ✅ Triggers centralized build in my-documents
- ✅ Provides detailed build status and links
- ✅ Handles all authentication securely

### 3.2. Full Documentation

For detailed documentation including advanced usage, troubleshooting, and migration guide:

**📖 [Trigger My-Documents Workflow Documentation](content/docs/my-documents/trigger-my-documents-workflow.md)**

Topics covered:

- Architecture and authentication flow
- Configuration options and input parameters
- Advanced usage examples
- Troubleshooting guide
- Migration from PAT-based approach
- Best practices and FAQ
