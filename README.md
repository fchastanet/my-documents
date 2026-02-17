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

- [Basic best practices](/docs/bash-scripts/00-basic-bestpractices/)
- [Linux best practices](/docs/bash-scripts/10-linuxcommands-bestpractices/)
- [Bats best practices](/docs/bash-scripts/20-bats-bestpractices/)

### 1.2. HowTos

- [How to write a Jenkinsfile](/docs/howtos/howto-write-jenkinsfile/)
- [How to write a Dockerfile](/docs/howtos/howto-write-dockerfile/)
- [How to write a docker-compose.yml file](/docs/howtos/howto-write-dockercompose/)
- [Saml2Aws](/docs/howtos/saml2aws/)

### 1.3. Lists

- [Test](/docs/lists/test/)
- [Web](/docs/lists/web/)

## 2. Documentation Site Built with Hugo

This repository contains documentation built with
[Hugo](https://gohugo.io/) static site generator and the
[Docsy](https://www.docsy.dev/) theme. All content is in Markdown format and
automatically published to GitHub Pages.

## 3. Building Locally

### 3.1. Prerequisites

- [Hugo Extended](https://gohugo.io/installation/) version 0.110+
- [Go](https://golang.org/doc/install) version 1.18+

### 3.2. Quick Start

#### 3.2.1. Install Hugo

**Linux:**

```bash
CGO_ENABLED=1 go install -tags extended github.com/gohugoio/hugo@latest
```

**Or download from [Hugo "extended" releases](https://github.com/gohugoio/hugo/releases)**

#### 3.2.2. Clone and Setup

```bash
git clone https://github.com/fchastanet/my-documents.git
cd my-documents

# Download Hugo theme and dependencies
hugo mod get -u
```

#### 3.2.3. Run Local Server

```bash
hugo server -D
```

The site will be available at `http://localhost:1313/my-documents/`

- `-D` flag includes draft pages
- Site auto-reloads on file changes
- Press `Ctrl+C` to stop the server

### 3.3. Building for Production

```bash
hugo --minify
```

Output is generated in the `public/` directory.

### 3.4. Checking Site Statistics

```bash
hugo --printI18nWarnings --printPathWarnings --printUnusedTemplates
```

## 4. Documentation Structure

The documentation is organized as follows:

```text
content/en/
├── _index.html              # Homepage
└── docs/
    ├── _index.md            # Docs landing page
    ├── bash-scripts/        # Bash scripting guides
    ├── howtos/              # How-to guides
    ├── lists/               # Reference lists
    └── other-projects/      # Links to related projects
```

### 4.1. Adding New Documentation

1. Create a Markdown file in the appropriate `content/en/docs/` subdirectory
2. Add frontmatter with title, description, and weight (for ordering)
3. Save and Hugo will automatically rebuild the site

Example:

```markdown
---
title: My New Page
description: Brief description of the page
weight: 10
---

Your content here...
```

## 5. Content Guidelines

- Keep Markdown files focused and well-organized
- Use ATX-style headers (`#`, `##`, etc.)
- Line length: 120 characters maximum (enforced by mdformat)
- Line endings: LF only
- Use relative links for internal navigation
- Code blocks should specify language: `` ```bash ```, `` ```yaml```, etc.

## 6. SEO Features

This site includes the following SEO optimizations:

- Static HTML pre-rendering for all content
- Automatic XML sitemap generation
- Responsive design and mobile-first approach
- Optimized page load performance
- Per-page metadata and structured data (JSON-LD)
- RSS feeds for content distribution
- Canonical URLs to prevent duplication
- Open Graph and Twitter card support
- Breadcrumb navigation with schema markup

## 7. CI/CD Pipelines

### 7.1. Hugo Build & Deploy (`hugo-build-deploy.yml`)

- Builds on push to `master` branch
- Validates build output
- Deploys to GitHub Pages automatically

### 7.2. Pre-commit Linting (`lint.yml`)

- Runs Markdown and code quality checks
- Auto-fixes formatting/linting issues
- Runs MegaLinter validation
