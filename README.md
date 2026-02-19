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
[![CI/CD](https://github.com/fchastanet/my-documents/actions/workflows/lint.yml/badge.svg)](https://github.com/fchastanet/my-documents/actions?query=workflow:%22Pre-commit+run%22+branch:master)
[![Hugo Build & Deploy](https://github.com/fchastanet/my-documents/actions/workflows/hugo-build-deploy.yml/badge.svg)](https://github.com/fchastanet/my-documents/actions?query=workflow:%22Deploy+Hugo%22+branch:master)
[![ProjectStatus](http://opensource.box.com/badges/active.svg)](http://opensource.box.com/badges "Project Status")
[![DeepSource](https://deepsource.io/gh/fchastanet/my-documents.svg/?label=active+issues&show_trend=true)](https://deepsource.io/gh/fchastanet/my-documents/?ref=repository-badge "DeepSource active issues")
[![DeepSource](https://deepsource.io/gh/fchastanet/my-documents.svg/?label=resolved+issues&show_trend=true)](https://deepsource.io/gh/fchastanet/my-documents/?ref=repository-badge "DeepSource resolved issues")

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

This section summarizes the orchestrator's technical architecture. For full details, see [Technical-Architecture.md](/docs/my-documents/Technical-Architecture.md).

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
