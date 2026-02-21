---
title: My Documents - Technical Architecture and Documentation Site Implementation
description: Overview of the technical architecture and implementation details of the My Documents documentation site built with Hugo
categories: [Documentation]
tags: [hugo, docsy, multi-site, documentation, static-site-generator, github-actions, ai-generated]
creationDate: "2026-02-18"
lastUpdated: "2026-02-18"
version: "1.0"
---

# My Documents - Technical Architecture and Documentation Site Implementation

<!--TOC-->

- [My Documents - Technical Architecture and Documentation Site Implementation](#my-documents---technical-architecture-and-documentation-site-implementation)
  - [1. Documentation Site Built with Hugo](#1-documentation-site-built-with-hugo)
  - [2. Building Locally](#2-building-locally)
    - [2.1. Prerequisites](#21-prerequisites)
    - [2.2. Quick Start](#22-quick-start)
      - [2.2.1. Install Hugo](#221-install-hugo)
      - [2.2.2. Clone and Setup](#222-clone-and-setup)
      - [2.2.3. Run Local Server](#223-run-local-server)
    - [2.3. Building for Production](#23-building-for-production)
    - [2.4. Checking Site Statistics](#24-checking-site-statistics)
  - [3. Multi-Site Orchestrator Architecture](#3-multi-site-orchestrator-architecture)
    - [3.1. Architecture Overview](#31-architecture-overview)
    - [3.2. Managed Documentation Sites](#32-managed-documentation-sites)
    - [3.3. Shared vs Site-Specific Resources](#33-shared-vs-site-specific-resources)
    - [3.4. How It Works](#34-how-it-works)
    - [3.5. Key Benefits](#35-key-benefits)
    - [3.6. Testing Multi-Site Locally](#36-testing-multi-site-locally)
    - [3.7. Makefile Commands](#37-makefile-commands)
  - [4. Creating a New Documentation Site](#4-creating-a-new-documentation-site)
    - [4.1. Prerequisites](#41-prerequisites)
    - [4.2. Step-by-Step Guide](#42-step-by-step-guide)
      - [4.2.1. Step 1: Prepare the New Repository](#421-step-1-prepare-the-new-repository)
      - [4.2.2. Step 2: Add Trigger Workflow](#422-step-2-add-trigger-workflow)
      - [4.2.3. Step 3: Create Site Configuration in my-documents](#423-step-3-create-site-configuration-in-my-documents)
      - [4.2.4. Step 4: Update Build Workflow Matrix](#424-step-4-update-build-workflow-matrix)
      - [4.2.5. Step 5: Configure GitHub (See Section 6 for details)](#425-step-5-configure-github-see-section-6-for-details)
      - [4.2.6. Step 6: Test Locally](#426-step-6-test-locally)
      - [4.2.7. Step 7: Commit and Deploy](#427-step-7-commit-and-deploy)
    - [4.3. Post-Creation Checklist](#43-post-creation-checklist)
  - [5. GitHub Configuration](#5-github-configuration)
    - [5.1. Architecture: GitHub App Authentication](#51-architecture-github-app-authentication)
    - [5.2. Required Secrets](#52-required-secrets)
      - [5.2.1. In my-documents Repository](#521-in-my-documents-repository)
      - [5.2.2. In Each Dependent Repository](#522-in-each-dependent-repository)
    - [5.3. Creating the GitHub App](#53-creating-the-github-app)
      - [5.3.1. Step 1: Create GitHub App](#531-step-1-create-github-app)
      - [5.3.2. Step 2: Note the App ID](#532-step-2-note-the-app-id)
      - [5.3.3. Step 3: Generate Private Key](#533-step-3-generate-private-key)
      - [5.3.4. Step 4: Install App on Repositories](#534-step-4-install-app-on-repositories)
      - [5.3.5. Step 5: Add Secrets to my-documents](#535-step-5-add-secrets-to-my-documents)
    - [5.4. Creating Personal Access Token (PAT)](#54-creating-personal-access-token-pat)
      - [5.4.1. Step 1: Create PAT](#541-step-1-create-pat)
      - [5.4.2. Step 2: Add to Each Dependent Repository](#542-step-2-add-to-each-dependent-repository)
    - [5.5. Repository Settings](#55-repository-settings)
      - [5.5.1. GitHub Pages Configuration](#551-github-pages-configuration)
      - [5.5.2. Branch Protection (Optional)](#552-branch-protection-optional)
  - [6. Repository Integration](#6-repository-integration)
    - [6.1. Files and Folder Structure](#61-files-and-folder-structure)
      - [6.1.1. Required Structure in Dependent Repository](#611-required-structure-in-dependent-repository)
      - [6.1.2. Required Structure in my-documents (Orchestrator)](#612-required-structure-in-my-documents-orchestrator)
    - [6.2. Migration Guide](#62-migration-guide)
    - [6.3. Content Organization Best Practices](#63-content-organization-best-practices)
    - [6.4. Repository Configuration in GitHub](#64-repository-configuration-in-github)
      - [6.4.1. Step 1: Add Required Secrets](#641-step-1-add-required-secrets)
      - [6.4.2. Step 2: Install GitHub App](#642-step-2-install-github-app)
      - [6.4.3. Step 3: Configure GitHub Pages](#643-step-3-configure-github-pages)
      - [6.4.4. Step 4: Verify Workflow Permissions](#644-step-4-verify-workflow-permissions)
      - [6.4.5. Step 5: Test the Integration](#645-step-5-test-the-integration)
      - [6.4.6. Common Integration Issues](#646-common-integration-issues)
  - [7. Authentication Setup Details](#7-authentication-setup-details)
    - [7.1. GitHub App vs Deploy Keys Comparison](#71-github-app-vs-deploy-keys-comparison)
    - [7.2. GitHub App Complete Setup](#72-github-app-complete-setup)
    - [7.3. Personal Access Token (PAT) Setup](#73-personal-access-token-pat-setup)
    - [7.4. Token Lifecycle and Rotation](#74-token-lifecycle-and-rotation)
      - [7.4.1. GitHub App Tokens](#741-github-app-tokens)
      - [7.4.2. Personal Access Tokens](#742-personal-access-tokens)
    - [7.5. Troubleshooting Authentication](#75-troubleshooting-authentication)
  - [8. Troubleshooting Multi-Site Builds](#8-troubleshooting-multi-site-builds)
    - [8.1. Build Failures](#81-build-failures)
      - [8.1.1. Issue: Matrix Build Fails for One Site](#811-issue-matrix-build-fails-for-one-site)
      - [8.1.2. Issue: All Sites Fail to Build](#812-issue-all-sites-fail-to-build)
    - [8.2. Configuration Merge Issues](#82-configuration-merge-issues)
      - [8.2.1. Issue: Site-Specific Config Not Applied](#821-issue-site-specific-config-not-applied)
      - [8.2.2. Issue: Configuration Merge Produces Invalid YAML](#822-issue-configuration-merge-produces-invalid-yaml)
    - [8.3. Deployment Failures](#83-deployment-failures)
      - [8.3.1. Issue: GitHub App Authentication Fails](#831-issue-github-app-authentication-fails)
      - [8.3.2. Issue: Deploy Succeeds but Site Not Updated](#832-issue-deploy-succeeds-but-site-not-updated)
    - [8.4. Trigger Issues](#84-trigger-issues)
      - [8.4.1. Issue: Repository Dispatch Not Triggering Build](#841-issue-repository-dispatch-not-triggering-build)
      - [8.4.2. Issue: Unwanted Builds (Too Many Triggers)](#842-issue-unwanted-builds-too-many-triggers)
    - [8.5. Content and Link Issues](#85-content-and-link-issues)
      - [8.5.1. Issue: Internal Links Return 404](#851-issue-internal-links-return-404)
      - [8.5.2. Issue: Images Not Displaying](#852-issue-images-not-displaying)
    - [8.6. Performance Issues](#86-performance-issues)
      - [8.6.1. Issue: Builds Taking Too Long](#861-issue-builds-taking-too-long)
    - [8.7. Debugging Checklist](#87-debugging-checklist)
  - [9. Advanced Configuration Topics](#9-advanced-configuration-topics)
    - [9.1. Configuration Merging Strategy](#91-configuration-merging-strategy)
      - [9.1.1. How yq Deep-Merge Works](#911-how-yq-deep-merge-works)
    - [9.2. Per-Site Theme Customization](#92-per-site-theme-customization)
      - [9.2.1. Theme Colors](#921-theme-colors)
      - [9.2.2. Custom Logos](#922-custom-logos)
      - [9.2.3. Custom CSS/SCSS](#923-custom-cssscss)
    - [9.3. SEO and Metadata Customization](#93-seo-and-metadata-customization)
      - [9.3.1. Per-Site SEO Keywords](#931-per-site-seo-keywords)
      - [9.3.2. Custom Metadata](#932-custom-metadata)
      - [9.3.3. Structured Data (JSON-LD)](#933-structured-data-json-ld)
    - [9.4. Menu Customization](#94-menu-customization)
      - [9.4.1. Custom Navigation Menu](#941-custom-navigation-menu)
      - [9.4.2. Footer Links](#942-footer-links)
    - [9.5. Performance Optimization](#95-performance-optimization)
      - [9.5.1. Image Optimization](#951-image-optimization)
      - [9.5.2. Minification](#952-minification)
      - [9.5.3. HTML Rendering Optimization](#953-html-rendering-optimization)
    - [9.6. Multi-Language Support](#96-multi-language-support)
    - [9.7. Search Configuration](#97-search-configuration)
  - [10. Contributing to the Orchestrator](#10-contributing-to-the-orchestrator)
    - [10.1. Types of Contributions](#101-types-of-contributions)
    - [10.2. Development Workflow](#102-development-workflow)
      - [10.2.1. Step 1: Fork and Clone](#1021-step-1-fork-and-clone)
      - [10.2.2. Step 2: Make Changes](#1022-step-2-make-changes)
      - [10.2.3. Step 3: Test Across All Sites](#1023-step-3-test-across-all-sites)
      - [10.2.4. Step 4: Commit with Conventional Commits](#1024-step-4-commit-with-conventional-commits)
    - [10.3. Testing Changes Locally](#103-testing-changes-locally)
      - [10.3.1. Test Shared Layout Changes](#1031-test-shared-layout-changes)
      - [10.3.2. Test Configuration Changes](#1032-test-configuration-changes)
      - [10.3.3. Test Workflow Changes](#1033-test-workflow-changes)
    - [10.4. Best Practices for Contributors](#104-best-practices-for-contributors)
      - [10.4.1. Shared Components](#1041-shared-components)
      - [10.4.2. Configuration Changes](#1042-configuration-changes)
      - [10.4.3. Workflow Improvements](#1043-workflow-improvements)
    - [10.5. Code Review Process](#105-code-review-process)
    - [10.6. Adding New Shared Features](#106-adding-new-shared-features)
      - [10.6.1. Example: Adding a New Partial](#1061-example-adding-a-new-partial)
    - [10.7. Release Process](#107-release-process)
      - [10.7.1. Versioning](#1071-versioning)
      - [10.7.2. Deprecation Policy](#1072-deprecation-policy)
    - [10.8. Getting Help](#108-getting-help)
  - [11. Documentation Structure](#11-documentation-structure)
    - [11.1. Adding New Documentation](#111-adding-new-documentation)
  - [12. Content Guidelines](#12-content-guidelines)
  - [13. SEO Features](#13-seo-features)
  - [14. CI/CD Pipelines](#14-cicd-pipelines)
    - [14.1. Build All Sites (build-all-sites.yml)](#141-build-all-sites-build-all-sitesyml)
    - [14.2. Hugo Build & Deploy (hugo-build-deploy.yml)](#142-hugo-build--deploy-hugo-build-deployyml)
    - [14.3. Pre-commit Linting (lint.yml)](#143-pre-commit-linting-lintyml)

<!--TOC-->

## 1. Documentation Site Built with Hugo

This repository contains documentation built with
[Hugo](https://gohugo.io/) static site generator and the
[Docsy](https://www.docsy.dev/) theme. All content is in Markdown format and
automatically published to GitHub Pages.

## 2. Building Locally

### 2.1. Prerequisites

- [Hugo Extended](https://gohugo.io/installation/) version 0.110+
- [Go](https://golang.org/doc/install) version 1.18+

### 2.2. Quick Start

#### 2.2.1. Install Hugo

**Linux:**

```bash
CGO_ENABLED=1 go install -tags extended github.com/gohugoio/hugo@latest
```

**Or download from [Hugo "extended" releases](https://github.com/gohugoio/hugo/releases)**

#### 2.2.2. Clone and Setup

```bash
git clone https://github.com/fchastanet/my-documents.git
cd my-documents

# Download Hugo theme and dependencies
hugo mod get -u
```

#### 2.2.3. Run Local Server

```bash
hugo server -D
```

The site will be available at `http://localhost:1313/my-documents/`

- `-D` flag includes draft pages
- Site auto-reloads on file changes
- Press `Ctrl+C` to stop the server

### 2.3. Building for Production

```bash
hugo --minify
```

Output is generated in the `public/` directory.

### 2.4. Checking Site Statistics

```bash
hugo --printI18nWarnings --printPathWarnings --printUnusedTemplates
```

## 3. Multi-Site Orchestrator Architecture

This repository serves as a **centralized orchestrator** that builds and deploys multiple documentation sites in a
coordinated fashion.

### 3.1. Architecture Overview

```text
┌─────────────────────────────────────────────────────────────────┐
│                    my-documents (Orchestrator)                   │
├─────────────────────────────────────────────────────────────────┤
│  • Shared Hugo theme and layouts (shared/)                      │
│  • Base configuration (configs/_base.yaml)                      │
│  • Site-specific configs (configs/*.yaml)                       │
│  • Build workflow (.github/workflows/build-all-sites.yml)       │
│  • Deployment orchestration (GitHub App authentication)         │
└────┬────────────┬────────────┬────────────┬─────────────────────┘
     │            │            │            │
     ▼            ▼            ▼            ▼
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│  bash-  │  │  bash-  │  │  bash-  │  │  bash-  │
│compiler │  │  tools  │  │  tools- │  │   dev-  │
│         │  │         │  │framework│  │   env   │
└─────────┘  └─────────┘  └─────────┘  └─────────┘
     │            │            │            │
     └────┬───────┴────────┬───┴────────┬───┘
          │                │            │
          ▼                ▼            ▼
    Push to master → Trigger orchestrator → Build all sites in parallel
          │                                        │
          └────────────────────────────────────────┘
                            │
                            ▼
                  Deploy to GitHub Pages
    (fchastanet.github.io/bash-compiler/, etc.)
```

### 3.2. Managed Documentation Sites

- Centralized orchestrator and documentation site
  - [My Documents deployment](https://fchastanet.github.io/my-documents/)
  - [My Documents GitHub Repository](https://github.com/fchastanet/my-documents)
- Documentation for the Bash Compiler project
  - [Bash Compiler deployment](https://fchastanet.github.io/bash-compiler/)
  - [Bash Compiler GitHub Repository](https://github.com/fchastanet/bash-compiler)
- Documentation for the Bash Tools project
  - [Bash Tools deployment](https://fchastanet.github.io/bash-tools/)
  - [Bash Tools GitHub Repository](https://github.com/fchastanet/bash-tools)
- Documentation for the Bash Tools Framework project
  - [Bash Tools Framework deployment](https://fchastanet.github.io/bash-tools-framework/)
  - [Bash Tools Framework GitHub Repository](https://github.com/fchastanet/bash-tools-framework)
- Documentation for the Bash Dev Env project
  - [Bash Dev Env deployment](https://fchastanet.github.io/bash-dev-env/)
  - [Bash Dev Env GitHub Repository](https://github.com/fchastanet/bash-dev-env)

### 3.3. Shared vs Site-Specific Resources

**Shared Resources (All Sites):**

- Hugo theme (Docsy) and version
- Common layouts and partials (`shared/layouts/`)
- Base SCSS variables and assets (`shared/assets/`)
- Content archetypes (`shared/archetypes/`)
- SEO structured data and meta tags
- Base configuration (`configs/_base.yaml`)

**Site-Specific Resources:**

- Documentation content (`content/`)
- Site configuration overrides (`configs/[site].yaml`)
- Theme colors and branding
- Navigation menu items
- Repository links and metadata
- Static assets specific to the site

### 3.4. How It Works

1. **Content Change:** Developer pushes changes to any managed repository (e.g., bash-compiler)
2. **Trigger:** Repository trigger workflow sends `repository_dispatch` event to my-documents orchestrator
3. **Checkout:** Orchestrator checks out all repositories
4. **Parallel Build:** GitHub Actions matrix builds all 5 sites simultaneously (~60s total)
5. **Config Merge:** Each site gets base config + site-specific overrides merged with `yq`
6. **Deploy:** Sites deployed to respective GitHub Pages using GitHub App authentication
7. **Result:** All documentation sites are updated and consistent

### 3.5. Key Benefits

- ✅ **Guaranteed Consistency:** All sites use the same Hugo theme version and shared components
- ✅ **Single-Point Updates:** Fix a bug once, deploy to all sites automatically
- ✅ **Simplified Per-Repo Setup:** Dependent repos need only 2 files (trigger workflow + content)
- ✅ **Fast Parallel Builds:** All 5 sites build simultaneously in ~60 seconds
- ✅ **Centralized Authentication:** One GitHub App manages deployments to all repositories
- ✅ **Configuration Flexibility:** Per-site customization while maintaining consistency

### 3.6. Testing Multi-Site Locally

To test multiple sites locally using symlinks:

**Step 1: Clone related repositories**

```bash
cd /path/to/your/workspace
git clone https://github.com/fchastanet/my-documents.git
git clone https://github.com/fchastanet/bash-compiler.git
git clone https://github.com/fchastanet/bash-tools.git
git clone https://github.com/fchastanet/bash-tools-framework.git
git clone https://github.com/fchastanet/bash-dev-env.git
```

**Step 2: Install dependencies**

```bash
cd my-documents
make install  # Installs Hugo, yq, npm packages, Go modules
```

**Step 3: Link repositories**

```bash
make link-repos  # Creates symlinks in sites/ directory
```

This creates:

```text
my-documents/sites/
├── bash-compiler -> ../../bash-compiler
├── bash-tools -> ../../bash-tools
├── bash-tools-framework -> ../../bash-tools-framework
└── bash-dev-env -> ../../bash-dev-env
```

**Step 4: Build and test**

```bash
# Build all sites
make build-all

# Test all sites with curl
make test-all

# Build a specific site
make build-site SITE=bash-compiler
```

**Step 5: Clean up**

```bash
# Remove symlinks
make unlink-repos

# Clean build artifacts
make clean
```

### 3.7. Makefile Commands

```bash
make help           # Show all available commands
make install        # Install all dependencies
make link-repos     # Create symlinks to other repos
make unlink-repos   # Remove symlinks
make build-all      # Build all sites locally
make build-site     # Build specific site (SITE=name)
make test-all       # Build and test all sites with curl
make start          # Start Hugo dev server (my-documents)
make build          # Build my-documents only
make clean          # Remove build artifacts
```

## 4. Creating a New Documentation Site

This section guides you through adding a new documentation site to the orchestrator.

### 4.1. Prerequisites

Before adding a new site, ensure:

- [ ] Repository exists and contains documentation to migrate
- [ ] You have admin access to both my-documents and the new repository
- [ ] Hugo Extended and Go are installed locally for testing
- [ ] You understand the orchestrator architecture (see Section 4)

### 4.2. Step-by-Step Guide

#### 4.2.1. Step 1: Prepare the New Repository

1. **Clone the repository:**

   ```bash
   git clone https://github.com/fchastanet/your-new-repo.git
   cd your-new-repo
   ```

2. **Create content structure:**

   ```bash
   mkdir -p content/en/docs
   ```

3. **Create homepage** (`content/en/_index.md`):

   ```yaml
   ---
   title: Your Project Name
   description: Brief project description
   ---

   Welcome to the documentation!

   ## Features

   - Feature 1
   - Feature 2
   ```

4. **Create docs landing page** (`content/en/docs/_index.md`):

   ```yaml
   ---
   title: Documentation
   description: Complete documentation for Your Project
   weight: 1
   ---
   ```

5. **Migrate existing content** (see Section 7.2 for detailed migration guide)

#### 4.2.2. Step 2: Add Trigger Workflow

Create `.github/workflows/trigger-docs.yml`:

```yaml
---
name: Trigger Documentation Rebuild

on:
  push:
    branches: [master]
    paths:
      - 'content/**'
      - 'static/**'
      - '.github/workflows/trigger-docs.yml'
  workflow_dispatch:

jobs:
  trigger:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger my-documents orchestrator
        uses: peter-evans/repository-dispatch@v3
        with:
          token: ${{ secrets.DOCS_BUILD_TOKEN }}
          repository: fchastanet/my-documents
          event-type: trigger-docs-rebuild
          client-payload: |
            {
              "repository": "${{ github.repository }}",
              "ref": "${{ github.ref }}",
              "sha": "${{ github.sha }}",
              "triggered_by": "${{ github.actor }}"
            }

      - name: Build triggered
        run: |
          echo "✅ Documentation build triggered in fchastanet/my-documents"
          echo "🔗 Check status: https://github.com/fchastanet/my-documents/actions"
```

#### 4.2.3. Step 3: Create Site Configuration in my-documents

1. **Clone my-documents:**

   ```bash
   cd /path/to/workspace
   git clone https://github.com/fchastanet/my-documents.git
   cd my-documents
   ```

2. **Create site config** (`configs/your-new-repo.yaml`):

   ```yaml
   baseURL: https://fchastanet.github.io/your-new-repo
   title: Your Project Name
   description: Brief description for SEO and meta tags

   params:
     description: Brief description for SEO and meta tags
     keywords:
       - keyword1
       - keyword2
       - keyword3

     # Theme color (hex color code)
     ui:
       navbar_bg_color: '#ff6600' # Choose a unique color

     # Repository links
     github_repo: https://github.com/fchastanet/your-new-repo
     github_project_repo: https://github.com/fchastanet/your-new-repo

     # Footer links
     links:
       user:
         - name: GitHub Repository
           url: https://github.com/fchastanet/your-new-repo
           icon: fab fa-github
   ```

#### 4.2.4. Step 4: Update Build Workflow Matrix

Edit `.github/workflows/build-all-sites.yml` and add your site to the matrix:

```yaml
matrix:
  site:
    # ... existing sites ...
    - name: your-new-repo
      repo: fchastanet/your-new-repo
      baseURL: 'https://fchastanet.github.io/your-new-repo'
      self: false
```

#### 4.2.5. Step 5: Configure GitHub (See Section 6 for details)

1. **Add Personal Access Token to new repository:**
   - Go to new repository → Settings → Secrets → Actions
   - Add secret: `DOCS_BUILD_TOKEN` (see Section 6.2)

2. **Install GitHub App on new repository** (see Section 6.3)

#### 4.2.6. Step 6: Test Locally

```bash
cd my-documents

# Link your new repository
ln -s ../../your-new-repo sites/your-new-repo

# Build the site
make build-site SITE=your-new-repo

# Test the output
cd build/your-new-repo
hugo server -D --port 1314
# Visit http://localhost:1314/your-new-repo/
```

#### 4.2.7. Step 7: Commit and Deploy

1. **Commit changes to my-documents:**

   ```bash
   cd my-documents
   git add configs/your-new-repo.yaml .github/workflows/build-all-sites.yml
   git commit -m "feat: add your-new-repo to orchestrator

   - Add site configuration with unique theme color
   - Update build matrix to include your-new-repo
   - Enable automated documentation deployment
   "
   git push origin master
   ```

2. **Commit trigger workflow to new repository:**

   ```bash
   cd your-new-repo
   git add .github/workflows/trigger-docs.yml content/
   git commit -m "feat: add Hugo content structure and orchestrator trigger

   - Migrate content to Hugo format
   - Add trigger workflow for my-documents orchestrator
   - Configure content structure for Docsy theme
   "
   git push origin master
   ```

3. **Verify deployment:**
   - Check my-documents Actions: <https://github.com/fchastanet/my-documents/actions>
   - Wait for build to complete (~60s)
   - Visit your site: `https://fchastanet.github.io/your-new-repo/`

### 4.3. Post-Creation Checklist

- [ ] Site builds successfully in ci/CD
- [ ] GitHub Pages deployment completes without errors
- [ ] Live site is accessible at expected URL
- [ ] Navigation works correctly
- [ ] Internal links resolve properly
- [ ] Images and static assets display correctly
- [ ] SEO meta tags are present (view source)
- [ ] Sitemap is generated: `https://fchastanet.github.io/your-new-repo/sitemap.xml`
- [ ] Mobile responsive layout works
- [ ] Search functionality works (Docsy local search)

## 5. GitHub Configuration

This section covers authentication, secrets, and repository settings required for the orchestrator.

### 5.1. Architecture: GitHub App Authentication

The orchestrator uses a **GitHub App** for secure, fine-grained authentication when deploying to dependent
repositories.

**Why GitHub App (vs Deploy Keys)?**

- ✅ **Fine-grained permissions:** Only Contents and Pages write access
- ✅ **Centralized management:** One app deploys to all repositories
- ✅ **Better security:** Automatic token expiration and rotation
- ✅ **Audit trail:** All actions logged under app identity
- ✅ **Easily scalable:** Add/remove repositories without generating new keys
- ✅ **Revocable:** Instantly revoke access from app settings

### 5.2. Required Secrets

#### 5.2.1. In my-documents Repository

| Secret Name           | Purpose                                | How to Obtain                                 |
| --------------------- | -------------------------------------- | --------------------------------------------- |
| `DOC_APP_ID`          | GitHub App ID for deployments          | Step 3 of GitHub App creation (Section 6.3)   |
| `DOC_APP_PRIVATE_KEY` | GitHub App private key (PEM format)    | Step 4 of GitHub App creation (Section 6.3)   |

#### 5.2.2. In Each Dependent Repository

| Secret Name         | Purpose                                 | How to Obtain                                 |
| ------------------- | --------------------------------------- | --------------------------------------------- |
| `DOCS_BUILD_TOKEN`  | Personal Access Token to trigger builds | Create PAT with `repo` scope (Section 6.4)    |

### 5.3. Creating the GitHub App

If the GitHub App doesn't exist yet, follow these steps:

#### 5.3.1. Step 1: Create GitHub App

1. Navigate to <https://github.com/settings/apps/new> (or Organization → Settings → GitHub Apps → New)

2. Fill in app details:

   ```text
   Name: My Documents Site Deployer
   Description: Deploys documentation sites to GitHub Pages for fchastanet projects
   Homepage URL: https://github.com/fchastanet/my-documents
   Callback URL: (leave blank)
   Webhook: ✗ Uncheck "Active"
   ```

3. Set repository permissions:

   ```text
   Repository permissions:
   - Contents: Read and write  ← Deploy to gh-pages branch
   - Pages: Read and write     ← Trigger GitHub Pages build
   - Metadata: Read-only       ← (automatic, required)
   ```

4. Where can this app be installed?

   ```text
   ○ Only on this account
   ```

5. Click **"Create GitHub App"**

#### 5.3.2. Step 2: Note the App ID

- App ID is displayed at the top of the app settings page
- Example: `App ID: 123456`
- You'll need this for `DOC_APP_ID` secret

#### 5.3.3. Step 3: Generate Private Key

1. Scroll to "Private keys" section
2. Click **"Generate a private key"**
3. Download the `.pem` file (e.g., `my-documents-site-deployer.2026-02-19.private-key.pem`)
4. **Store securely** (password manager or encrypted storage)

⚠️ **Security Warning:** Private key provides write access to repositories. Never commit it to git.

#### 5.3.4. Step 4: Install App on Repositories

1. In app settings → **"Install App"** (left sidebar)
2. Click **"Install"** next to your account (fchastanet)
3. Select **"Only select repositories"**
4. Choose repositories:
   - `bash-compiler`
   - `bash-tools`
   - `bash-tools-framework`
   - `bash-dev-env`
   - *(Add your new repository here)*
5. Click **"Install"**

#### 5.3.5. Step 5: Add Secrets to my-documents

1. Go to <https://github.com/fchastanet/my-documents/settings/secrets/actions>
2. Click **"New repository secret"**

**Secret 1: DOC_APP_ID**

```text
Name: DOC_APP_ID
Value: 123456  # Your App ID from Step 2
```

**Secret 2: DOC_APP_PRIVATE_KEY**

```text
Name: DOC_APP_PRIVATE_KEY
Value: # Paste ENTIRE content of .pem file, including BEGIN/END lines
```

### 5.4. Creating Personal Access Token (PAT)

Each dependent repository needs a Personal Access Token to trigger builds in my-documents.

#### 5.4.1. Step 1: Create PAT

1. Go to <https://github.com/settings/tokens>
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Fill in details:

   ```text
   Note: Documentation Build Trigger
   Expiration: No expiration (or 1 year)
   Scopes:
     ✅ repo (Full control of private repositories)
       ✅ repo:status
       ✅ repo_deployment
       ✅ public_repo
   ```

4. Click **"Generate token"**
5. **Copy the token immediately** (you won't see it again)

#### 5.4.2. Step 2: Add to Each Dependent Repository

For each repository (bash-compiler, bash-tools, etc.):

1. Go to repository → Settings → Secrets and variables → Actions
2. Click **"New repository secret"**
3. Add:

   ```text
   Name: DOCS_BUILD_TOKEN
   Value: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  # Your PAT
   ```

### 5.5. Repository Settings

#### 5.5.1. GitHub Pages Configuration

For each dependent repository:

1. Go to repository → Settings → Pages
2. **Source:** Deploy from a branch
3. **Branch:** `gh-pages` / `(root)`
4. **Custom domain:** (leave blank unless you have one)
5. **Enforce HTTPS:** ✅ Checked

The orchestrator will create and manage the `gh-pages` branch automatically.

#### 5.5.2. Branch Protection (Optional)

For `master` branch in dependent repositories:

1. Go to repository → Settings → Branches
2. Add rule for `master`:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass (Documentation build)
   - ✅ Require branches to be up to date

## 6. Repository Integration

This section covers integrating an existing or new repository into the orchestrator.

### 6.1. Files and Folder Structure

#### 6.1.1. Required Structure in Dependent Repository

```text
your-new-repo/
├── .github/
│   └── workflows/
│       └── trigger-docs.yml          ← Triggers orchestrator (required)
├── content/
│   └── en/
│       ├── _index.md                 ← Homepage (required)
│       └── docs/
│           ├── _index.md             ← Docs landing page (required)
│           └── *.md                  ← Documentation pages
├── static/                           ← Static assets (optional)
│   ├── images/
│   └── downloads/
├── README.md                         ← Repository README (recommended)
└── LICENSE                           ← License file (recommended)
```

**Not Required in Dependent Repository:**

- ❌ `hugo.yaml` (generated by orchestrator from configs/)
- ❌ `go.mod` / `go.sum` (managed by orchestrator)
- ❌ Hugo build workflows (orchestrator handles this)
- ❌ Theme files (shared from my-documents)

#### 6.1.2. Required Structure in my-documents (Orchestrator)

```text
my-documents/
├── configs/
│   ├── _base.yaml                    ← Shared base config
│   └── your-new-repo.yaml            ← Site-specific overrides
├── shared/
│   ├── layouts/                      ← Shared Hugo templates
│   ├── assets/                       ← Shared SCSS, JS
│   └── archetypes/                   ← Content templates
└── .github/workflows/
    └── build-all-sites.yml           ← Orchestrator workflow (update matrix)
```

### 6.2. Migration Guide

For detailed migration from Docsify or other static site generators to Hugo, see:

**📄 [Complete Migration Guide](doc/ai/2026-02-18-migrate-repo-from-docsify-to-hugo.md)**

The migration guide covers:

- Analyzing current documentation structure
- Converting Docsify/other formats to Hugo content structure
- Content migration strategies (markdown conversion)
- Adding proper frontmatter to all pages
- Updating internal links and image references
- Testing migration locally
- Validation checklist

**Quick Migration Overview:**

1. **Analyze current structure** - Identify all documentation files and organization
2. **Create Hugo content structure** - `content/en/docs/` hierarchy
3. **Add frontmatter** - Title, description, weight to all pages
4. **Convert content** - Update syntax, links, shortcodes
5. **Migrate assets** - Move to `static/` directory
6. **Test locally** - Build with orchestrator, verify output
7. **Deploy** - Commit and push to trigger automated build

### 6.3. Content Organization Best Practices

**Directory Structure Example:**

```text
content/en/docs/
├── _index.md                         # Docs landing page (weight: 1)
├── getting-started/
│   ├── _index.md                     # Section landing (weight: 10)
│   ├── installation.md               # (weight: 10)
│   ├── quickstart.md                 # (weight: 20)
│   └── configuration.md              # (weight: 30)
├── guides/
│   ├── _index.md                     # (weight: 20)
│   ├── basic-usage.md
│   └── advanced-topics.md
└── reference/
    ├── _index.md                     # (weight: 30)
    ├── api.md
    └── cli.md
```

**Frontmatter Template:**

```yaml
---
title: Page Title
description: Brief description for SEO (100-160 characters recommended)
weight: 10                            # Lower numbers appear first in navigation
categories: [documentation]           # Optional categories
tags: [bash, linux, tutorial]         # Optional tags
---
```

**Navigation Ordering:**

- Hugo uses `weight` to order pages (ascending order)
- Lower weight = higher in menu (10 before 20)
- Same weight = alphabetical order by title
- Section `_index.md` establishes section weight

### 6.4. Repository Configuration in GitHub

After creating content and workflows, configure the repository:

#### 6.4.1. Step 1: Add Required Secrets

See Section 6.2 and 6.4 for details.

1. Add `DOCS_BUILD_TOKEN` secret to dependent repository
2. Ensure my-documents has `DOC_APP_ID` and `DOC_APP_PRIVATE_KEY`

#### 6.4.2. Step 2: Install GitHub App

See Section 6.3, Step 4 for details.

1. Go to <https://github.com/settings/installations>
2. Click "Configure" on "My Documents Site Deployer"
3. Add your repository to "Repository access"
4. Click "Save"

#### 6.4.3. Step 3: Configure GitHub Pages

1. Go to repository → Settings → Pages
2. Source: **Deploy from a branch**
3. Branch: **gh-pages** / (root)
4. Click "Save"

⚠️ **Note:** The `gh-pages` branch will be created automatically on first deployment. Don't create it manually.

#### 6.4.4. Step 4: Verify Workflow Permissions

1. Go to repository → Settings → Actions → General
2. Workflow permissions:
   - ✅ **Read and write permissions**  (for creating gh-pages branch)
   - ✅ **Allow GitHub Actions to create and approve pull requests** (optional)

#### 6.4.5. Step 5: Test the Integration

1. **Make a test commit** to content:

   ```bash
   cd your-new-repo
   echo "Test update" >> content/en/docs/_index.md
   git add content/en/docs/_index.md
   git commit -m "test: trigger documentation build"
   git push origin master
   ```

2. **Verify trigger workflow** runs in your repository:
   - Go to <https://github.com/fchastanet/your-new-repo/actions>
   - Check "Trigger Documentation Rebuild" workflow succeeded

3. **Verify orchestrator build** in my-documents:
   - Go to <https://github.com/fchastanet/my-documents/actions>
   - Check "Build All Documentation Sites" workflow running
   - Look for your site in the matrix build jobs

4. **Verify deployment:**
   - Wait for build to complete (~60s)
   - Visit `https://fchastanet.github.io/your-new-repo/`
   - Check that test update is visible

#### 6.4.6. Common Integration Issues

| Issue                          | Solution                                                   |
| ------------------------------ | ---------------------------------------------------------- |
| Trigger workflow fails         | Check `DOCS_BUILD_TOKEN` secret exists and is valid        |
| Build workflow fails           | Check GitHub App installed on repository                   |
| Deployment fails               | Check `gh-pages` branch permissions and Pages settings     |
| Site not accessible            | Wait 2-3 minutes for GitHub Pages propagation              |
| 404 on site                    | Check `baseURL in configs/your-new-repo.yaml`              |

## 7. Authentication Setup Details

This section provides comprehensive details on authentication mechanisms.

### 7.1. GitHub App vs Deploy Keys Comparison

| Feature                  | GitHub App (Recommended)      | Deploy Keys                           |
| ------------------------ | ----------------------------- | ------------------------------------- |
| **Secrets Required**     | 2 (App ID + Private Key)      | N (one per repository)                |
| **Permissions**          | Fine-grained (Contents, Pages)| Full repository access                |
| **Token Expiration**     | Automatic (1 hour)            | Never (manual rotation needed)        |
| **Scalability**          | Easy (add repos to app)       | Creates new key pair per repo         |
| **Audit Trail**          | Full (logged as app)          | Limited (logged as deploy key)        |
| **Revocation**           | Instant (uninstall app)       | Per-key (delete each key)             |
| **Setup Complexity**     | Medium (one-time)             | Low (per repo)                        |
| **GitHub Recommendation**| ✅ Yes                        | ❌ Deprecated for this use case       |

**Conclusion:** GitHub App is the better choice for the orchestrator architecture.

### 7.2. GitHub App Complete Setup

See Section 6.3 for step-by-step instructions.

**Quick Reference:**

1. Create app at <https://github.com/settings/apps/new>
2. Set permissions: Contents (write), Pages (write)
3. Generate and download private key (.pem file)
4. Note the App ID
5. Install app on target repositories
6. Add `DOC_APP_ID` and `DOC_APP_PRIVATE_KEY` to my-documents secrets

### 7.3. Personal Access Token (PAT) Setup

See Section 6.4 for step-by-step instructions.

**Quick Reference:**

1. Create PAT at <https://github.com/settings/tokens>
2. Scopes: `repo` (full control)
3. Expiration: No expiration or 1 year
4. Add `DOCS_BUILD_TOKEN` to each dependent repository

**Security Note:** PAT has full `repo` access. It's used only to trigger `repository_dispatch` events, which is a
safe operation. Still, protect it like a password.

### 7.4. Token Lifecycle and Rotation

#### 7.4.1. GitHub App Tokens

- **Lifetime:** 1 hour (automatic)
- **Rotation:** Automatic (new token generated each build)
- **Manual Rotation:** Regenerate private key in app settings if compromised

#### 7.4.2. Personal Access Tokens

- **Lifetime:** As configured (no expiration or 1 year)
- **Rotation:** Manual
- **Best Practice:** Rotate annually or when team members leave

**To Rotate PAT:**

1. Create new PAT (Section 6.4)
2. Update `DOCS_BUILD_TOKEN` in all dependent repositories
3. Delete old PAT from <https://github.com/settings/tokens>

### 7.5. Troubleshooting Authentication

| Issue                            | Diagnosis                         | Solution                                     |
| -------------------------------- | --------------------------------- | -------------------------------------------- |
| "Bad credentials" error          | GitHub App token expired/invalid  | Check `DOC_APP_ID` and `DOC_APP_PRIVATE_KEY` |
| "Resource not accessible" error  | GitHub App not installed on repo  | Install app on repository (Section 6.3.4)    |
| Trigger workflow unauthorized    | PAT invalid or insufficient scope | Regenerate PAT with `repo` scope             |
|                                  |                                   | (Section 6.4)                                |
| Deploy fails with 403            | GitHub App lacks Pages permission | Check app permissions (Section 6.3.1)        |
| Token generation fails           | Private key malformed             | Re-download .pem file, ensure complete copy  |

## 8. Troubleshooting Multi-Site Builds

This section covers common issues and solutions specific to the orchestrator.

### 8.1. Build Failures

#### 8.1.1. Issue: Matrix Build Fails for One Site

**Symptoms:**

- One site fails while others succeed
- Error message specific to site content or configuration

**Diagnosis:**

1. Check GitHub Actions logs for the failing site
2. Look for errors in the matrix job output
3. Identify if it's a content issue or configuration issue

**Solutions:**

```bash
# Test site locally to reproduce error
cd my-documents
make build-site SITE=failing-site-name

# Check configuration merge
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
  configs/_base.yaml \
  configs/failing-site.yaml

# Validate content frontmatter
grep -r "^---$" sites/failing-site/content/
```

#### 8.1.2. Issue: All Sites Fail to Build

**Symptoms:**

- Entire matrix fails
- Error occurs before individual site builds

**Common Causes:**

1. Hugo version incompatibility
2. yq installation failure
3. Go module resolution issues
4. Base configuration syntax error

**Solutions:**

1. Check Hugo version in workflow matches local: `0.155.3`
2. Verify yq installation step succeeded
3. Check `configs/_base.yaml` for YAML syntax errors:

   ```bash
   yq eval configs/_base.yaml
   ```

4. Review workflow logs for specific error messages

### 8.2. Configuration Merge Issues

#### 8.2.1. Issue: Site-Specific Config Not Applied

**Symptoms:**

- Site uses base configuration instead of overrides
- Theme color or title not correct

**Diagnosis:**

```bash
# Test configuration merge locally
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
  configs/_base.yaml \
  configs/your-site.yaml

# Check if keys are being merged (should be combined, not duplicated)
```

**Solutions:**

1. Ensure site config uses correct YAML syntax (2-space indentation)
2. Verify override keys match base config structure
3. Use `yq` deep-merge syntax (not simple concatenation)

#### 8.2.2. Issue: Configuration Merge Produces Invalid YAML

**Symptoms:**

- `yq` merge succeeds but Hugo fails to parse `hugo.yaml`
- YAML syntax errors in workflow

**Solutions:**

```bash
# Validate both configs individually
yq eval configs/_base.yaml
yq eval configs/your-site.yaml

# Test merge and validate result
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
  configs/_base.yaml \
  configs/your-site.yaml | yq eval -

# Common issues:
# - Missing quotes around URLs
# - Incorrect indentation (use 2 spaces, not tabs)
# - Invalid YAML anchors or aliases
```

### 8.3. Deployment Failures

#### 8.3.1. Issue: GitHub App Authentication Fails

**Symptoms:**

- Error: "Could not authenticate with GitHub App"
- Deploy step fails with 401 or 403

**Solutions:**

1. Verify secrets exist in my-documents:

   ```bash
   # Check in GitHub UI
   # https://github.com/fchastanet/my-documents/settings/secrets/actions
   # Ensure DOC_APP_ID and DOC_APP_PRIVATE_KEY are set
   ```

2. Verify GitHub App is installed on target repository:

   ```bash
   # Check installations
   # https://github.com/settings/installations
   # Click "Configure" → Verify repository is in access list
   ```

3. Verify app permissions (Contents: write, Pages: write)

#### 8.3.2. Issue: Deploy Succeeds but Site Not Updated

**Symptoms:**

- Deploy step succeeds in workflow
- GitHub Pages still shows old content

**Solutions:**

1. **Check gh-pages branch:**

   ```bash
   # Clone repository
   git clone https://github.com/fchastanet/your-site.git
   cd your-site
   git checkout gh-pages
   git log -1  # Check latest commit timestamp
   ```

2. **Clear GitHub Actions cache:**
   - Go to repository → Actions → Caches
   - Delete all caches
   - Re-run workflow

3. **Wait for propagation:**
   - GitHub Pages can take 2-3 minutes to update
   - Check deployment status in repository → Settings → Pages

4. **Verify Pages settings:**
   - Source: Deploy from a branch
   - Branch: gh-pages / (root)

### 8.4. Trigger Issues

#### 8.4.1. Issue: Repository Dispatch Not Triggering Build

**Symptoms:**

- Commit to dependent repository doesn't trigger my-documents build
- Trigger workflow succeeds but orchestrator doesn't run

**Solutions:**

1. **Verify PAT has correct scope:**

   ```bash
   # PAT must have 'repo' scope
   # Check: https://github.com/settings/tokens
   # Regenerate if necessary (Section 6.4)
   ```

2. **Check event type matches:**

   ```yaml
   # In trigger workflow (dependent repo)
   event-type: trigger-docs-rebuild

   # Must match orchestrator workflow
   on:
     repository_dispatch:
       types: [trigger-docs-rebuild]  # Must match exactly
   ```

3. **Verify secret name:**

   ```yaml
   # In trigger workflow
   token: ${{ secrets.DOCS_BUILD_TOKEN }}  # Must be this exact name
   ```

4. **Check workflow logs** in dependent repository for API errors

#### 8.4.2. Issue: Unwanted Builds (Too Many Triggers)

**Symptoms:**

- Builds trigger on every commit
- Builds trigger even when only README changes

**Solutions:**

Update `paths` filter in trigger workflow:

```yaml
on:
  push:
    branches: [master]
    paths:
      - 'content/**'        # Only content changes
      - 'static/**'         # Only static asset changes
      # Remove other paths if too many triggers
```

### 8.5. Content and Link Issues

#### 8.5.1. Issue: Internal Links Return 404

**Symptoms:**

- Navigation works but internal links broken
- Links work locally but not on deployed site

**Solutions:**

1. **Use Hugo shortcodes for internal links:**
  escaped here to prevent rendering by hugo

   ```markdown
   \{\{< ref "/docs/section/page" >\}\}
   ```

2. **Use relative paths without .md extension:**

   ```markdown
   [Link text](/docs/section/page/)
   ```

3. **Avoid absolute URLs for internal links:**

   ```markdown
   ❌ [Bad](https://fchastanet.github.io/site/docs/page/)
   ✅ [Good](/docs/page/)
   ```

#### 8.5.2. Issue: Images Not Displaying

**Symptoms:**

- Images work locally but 404 on deployed site

**Solutions:**

1. **Use correct path from static directory:**

   ```markdown
   # File: static/images/diagram.png
   ![Diagram](/images/diagram.png)  ✅
   ![Diagram](images/diagram.png)   ❌
   ```

2. **Verify image exists in static directory:**

   ```bash
   ls -la sites/your-site/static/images/
   ```

3. **Check build output includes images:**

   ```bash
   ls -la build/your-site/public/images/
   ```

### 8.6. Performance Issues

#### 8.6.1. Issue: Builds Taking Too Long

**Symptoms:**

- Build time exceeds 5 minutes
- Workflow times out

**Solutions:**

1. **Enable matrix parallelization** (already enabled):

   ```yaml
   strategy:
     fail-fast: false  # Ensures parallel execution
   ```

2. **Reduce content size:**
   - Optimize images (compress, resize)
   - Remove unused static assets
   - Archive old documentation versions

3. **Cache Hugo modules (future optimization):**

   ```yaml
   # Add caching step
   - name: Cache Hugo modules
     uses: actions/cache@v4
     with:
       path: |
         ~/.cache/hugo_cache
         /tmp/hugo_cache
       key: hugo-modules-${{ hashFiles('**/go.sum') }}
   ```

### 8.7. Debugging Checklist

When troubleshooting, follow this systematic approach:

1. **Identify the failure point:**
   - [ ] Trigger workflow (dependent repo)
   - [ ] Orchestrator workflow started
   - [ ] Specific site build failed
   - [ ] Deployment failed
   - [ ] Site not accessible

2. **Gather information:**
   - [ ] Check GitHub Actions logs
   - [ ] Review error messages
   - [ ] Check workflow run details
   - [ ] Visit repository deployment status

3. **Reproduce locally:**
   - [ ] Clone repository
   - [ ] Run `make build-site SITE=failing-site`
   - [ ] Check local build output

4. **Verify configuration:**
   - [ ] YAML syntax valid
   - [ ] Secrets exist and are correct
   - [ ] GitHub App installed
   - [ ] Permissions configured

5. **Test incrementally:**
   - [ ] Test config merge
   - [ ] Test Hugo build
   - [ ] Test with minimal content
   - [ ] Add content gradually

## 9. Advanced Configuration Topics

This section covers advanced customization and optimization techniques.

### 9.1. Configuration Merging Strategy

#### 9.1.1. How yq Deep-Merge Works

The orchestrator uses `yq` for proper YAML deep-merging (not simple concatenation):

```bash
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
  configs/_base.yaml \
  configs/site-specific.yaml > hugo.yaml
```

**Behavior:**

- **Scalar values:** Site-specific overrides base (complete replacement)
- **Objects:** Deep merge (combine keys from both)
- **Arrays:** Site-specific replaces base entirely (not appended)

**Example:**

```yaml
# configs/_base.yaml
params:
  ui:
    navbar_bg_color: '#333333'
    sidebar_width: 250px
  keywords:
    - documentation
    - hugo

# configs/bash-compiler.yaml
params:
  ui:
    navbar_bg_color: '#007bff'
  keywords:
    - bash
    - compiler

# Merged result
params:
  ui:
    navbar_bg_color: '#007bff'    # Overridden
    sidebar_width: 250px          # Inherited from base
  keywords:                       # Array replaced entirely
    - bash
    - compiler
```

### 9.2. Per-Site Theme Customization

#### 9.2.1. Theme Colors

Each site can have unique branding:

```yaml
# configs/your-site.yaml
params:
  ui:
    navbar_bg_color: '#ff6600'      # Navbar background
    navbar_text_color: '#ffffff'    # Navbar text
    sidebar_bg_color: '#f8f9fa'     # Sidebar background
```

**Color Palette Recommendations:**

- my-documents: `#663399` (Deep Purple)
- bash-compiler: `#007bff` (Blue)
- bash-tools: `#28a745` (Green)
- bash-tools-framework: `#dc3545` (Red)
- bash-dev-env: `#fd7e14` (Orange)

#### 9.2.2. Custom Logos

Override logo per site:

```yaml
# configs/your-site.yaml
params:
  ui:
    navbar_logo: /images/logo.svg
    sidebar_logo: /images/logo-sidebar.svg
```

Place logos in dependent repository:

```bash
# your-site/static/images/logo.svg
# your-site/static/images/logo-sidebar.svg
```

#### 9.2.3. Custom CSS/SCSS

**Option 1: Site-specific SCSS in shared/**

```scss
// shared/assets/scss/_variables_project.scss
$custom-your-site-color: #ff6600;
```

**Option 2: Site-specific CSS in dependent repo**

```css
/* your-site/static/css/custom.css */
.navbar {
  background-color: #ff6600 !important;
}
```

Reference in config:

```yaml
# configs/your-site.yaml
params:
  custom_css:
    - /css/custom.css
```

### 9.3. SEO and Metadata Customization

#### 9.3.1. Per-Site SEO Keywords

```yaml
# configs/your-site.yaml
params:
  description: Comprehensive documentation for Your Project Name
  keywords:
    - your
    - specific
    - keywords
```

#### 9.3.2. Custom Metadata

Add custom meta tags via site config:

```yaml
params:
  meta_tags:
    - name: "author"
      content: "Your Name"
    - name: "og:type"
      content: "website"
```

#### 9.3.3. Structured Data (JSON-LD)

Shared structured data is in `shared/layouts/partials/hooks/head-end.html`. Customize per site:

```html
<!-- Create: sites/your-site/layouts/partials/hooks/head-end.html -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "Your Project",
  "description": "Project description",
  "url": "{{ .Site.BaseURL }}"
}
</script>
```

### 9.4. Menu Customization

#### 9.4.1. Custom Navigation Menu

Override default menu per site:

```yaml
# configs/your-site.yaml
menu:
  main:
    - name: Documentation
      url: /docs/
      weight: 10
    - name: Guides
      url: /docs/guides/
      weight: 20
    - name: API
      url: /docs/api/
      weight: 30
    - name: GitHub
      url: https://github.com/fchastanet/your-site
      weight: 40
```

#### 9.4.2. Footer Links

```yaml
params:
  links:
    user:
      - name: GitHub
        url: https://github.com/fchastanet/your-site
        icon: fab fa-github
      - name: Issues
        url: https://github.com/fchastanet/your-site/issues
        icon: fas fa-bug
    developer:
      - name: Contribute
        url: https://github.com/fchastanet/your-site/blob/master/CONTRIBUTING.md
        icon: fas fa-code
```

### 9.5. Performance Optimization

#### 9.5.1. Image Optimization

Hugo can process and optimize images:

```yaml
# configs/_base.yaml (already configured)
imaging:
  resampleFilter: CatmullRom
  quality: 75
  anchor: smart
```

Use responsive images in content:

```markdown
{{< figure src="/images/large-image.png" width="600px" alt="Description" >}}
```

#### 9.5.2. Minification

Already enabled in build workflow:

```bash
hugo --minify
```

This minifies:

- HTML
- CSS
- JavaScript
- JSON
- XML

#### 9.5.3. HTML Rendering Optimization

```yaml
# configs/_base.yaml
markup:
  goldmark:
    renderer:
      unsafe: false           # Security: disable raw HTML
  highlight:
    anchorLineNos: false     # Faster: no line number anchors
    lineNos: false           # Faster: no line numbers
    lineNumbersInTable: false
```

### 9.6. Multi-Language Support

Hugo/Docsy supports multiple languages. To add:

```yaml
# configs/your-site.yaml
languages:
  en:
    title: Your Project
    description: English description
    languageName: English
    weight: 1
  fr:
    title: Votre Project
    description: Description française
    languageName: Français
    weight: 2
```

Create content:

```bash
content/en/docs/guide.md
content/fr/docs/guide.md
```

### 9.7. Search Configuration

Docsy includes local search (already configured). To customize:

```yaml
# configs/your-site.yaml
params:
  search:
    algolia:
      enabled: false         # Use local search (default)
  offlineSearch: true        # Enable offline search index
  offlineSearchMaxResults: 20
  offlineSearchSummaryLength: 200
```

## 10. Contributing to the Orchestrator

This section guides contributors who want to improve the orchestrator itself.

### 10.1. Types of Contributions

**Shared Components:**

- Layouts and partials (`shared/layouts/`)
- SCSS variables and styles (`shared/assets/`)
- Content archetypes (`shared/archetypes/`)
- SEO enhancements (`shared/layouts/partials/hooks/`)

**Configuration:**

- Base configuration improvements (`configs/_base.yaml`)
- New site additions (site-specific configs)

**Workflows:**

- Build optimizations (`.github/workflows/build-all-sites.yml`)
- New optional workflows (testing, validation)

**Documentation:**

- README improvements
- Troubleshooting guide additions
- Migration guide updates

### 10.2. Development Workflow

#### 10.2.1. Step 1: Fork and Clone

```bash
git clone https://github.com/fchastanet/my-documents.git
cd my-documents
git checkout -b feature/your-improvement
```

#### 10.2.2. Step 2: Make Changes

1. **Edit shared components** in `shared/`
2. **Test changes locally** (see Section 11.3)
3. **Verify all sites** still build correctly

#### 10.2.3. Step 3: Test Across All Sites

```bash
# Link all repositories
make link-repos

# Build all sites
make build-all

# Test all sites
make test-all
```

#### 10.2.4. Step 4: Commit with Conventional Commits

```bash
git add shared/layouts/partials/your-change.html
git commit -m "feat: add new partial for feature X

- Add partial to enhance functionality
- Update documentation
- Test across all sites
"
```

### 10.3. Testing Changes Locally

#### 10.3.1. Test Shared Layout Changes

```bash
# Build specific site to test layout
make build-site SITE=bash-compiler

# Start local server
cd build/bash-compiler
hugo server -D --port 1314

# Visit http://localhost:1314/bash-compiler/
```

#### 10.3.2. Test Configuration Changes

```bash
# Test config merge
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
  configs/_base.yaml \
  configs/bash-compiler.yaml | tee /tmp/test-config.yaml

# Build with test config
hugo --config /tmp/test-config.yaml --minify
```

#### 10.3.3. Test Workflow Changes

1. **Push to your fork:**

   ```bash
   git push origin feature/your-improvement
   ```

2. **Create PR** to fchastanet/my-documents

3. **Workflow will run** on PR (test build before merge)

### 10.4. Best Practices for Contributors

#### 10.4.1. Shared Components

- **Test across all sites** before committing
- **Keep changes backward compatible** (don't break existing sites)
- **Document new features** in comments and README
- **Use descriptive variable names** in layouts/partials

#### 10.4.2. Configuration Changes

- **Preserve base config integrity** (don't remove existing keys)
- **Document new parameters** in comments
- **Test config merge** with all site-specific configs
- **Validate YAML syntax** before committing

#### 10.4.3. Workflow Improvements

- **Test workflow changes in fork** before PR
- **Ensure backward compatibility** with existing triggers
- **Document workflow parameters** in comments
- **Keep build times efficient** (avoid unnecessary steps)

### 10.5. Code Review Process

1. **Create PR** with descriptive title and description
2. **Ensure CI passes** (lint workflow)
3. **Request review** from maintainers
4. **Address feedback** promptly
5. **Squash and merge** after approval

### 10.6. Adding New Shared Features

#### 10.6.1. Example: Adding a New Partial

1. **Create partial:**

   ```html
   <!-- shared/layouts/partials/custom-feature.html -->
   <div class="custom-feature">
     {{ .Inner }}
   </div>
   ```

2. **Reference in base layout:**

   ```html
   <!-- shared/layouts/partials/hooks/head-end.html -->
   {{ partial "custom-feature.html" . }}
   ```

3. **Test across all sites:**

   ```bash
   make build-all
   ```

4. **Document usage:**

   Update README with usage instructions

### 10.7. Release Process

#### 10.7.1. Versioning

The orchestrator doesn't use semantic versioning (continuous deployment), but significant changes should be
documented:

1. **Update CHANGELOG.md** (create if doesn't exist)
2. **Tag release** for major changes:

   ```bash
   git tag -a v2.0.0 -m "Release v2.0.0: Multi-site orchestrator"
   git push origin v2.0.0
   ```

#### 10.7.2. Deprecation Policy

When deprecating features:

1. **Announce deprecation** in README and PR
2. **Keep deprecated feature** for 1 month minimum
3. **Provide migration path** in documentation
4. **Remove after grace period**

### 10.8. Getting Help

- **Issues:** <https://github.com/fchastanet/my-documents/issues>
- **Discussions:** <https://github.com/fchastanet/my-documents/discussions>
- **Documentation:** This README and related guides

## 11. Documentation Structure

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

### 11.1. Adding New Documentation

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

## 12. Content Guidelines

- Keep Markdown files focused and well-organized
- Use ATX-style headers (`#`, `##`, etc.)
- Line length: 120 characters maximum (enforced by mdformat)
- Line endings: LF only
- Use relative links for internal navigation
- Code blocks should specify language: `` ```bash ```, `` ```yaml```, etc.

## 13. SEO Features

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

## 14. CI/CD Pipelines

### 14.1. Build All Sites (build-all-sites.yml)

Centralized orchestrator that:

- Builds all documentation sites in parallel
- Merges base + site-specific configs using `yq`
- Deploys each site to its own GitHub Pages
- Triggers on push to `master` or via `repository_dispatch`

### 14.2. Hugo Build & Deploy (hugo-build-deploy.yml)

- Builds my-documents site only
- Validates build output
- Deploys to GitHub Pages automatically

### 14.3. Pre-commit Linting (lint.yml)

- Runs Markdown and code quality checks
- Auto-fixes formatting/linting issues
- Runs MegaLinter validation
