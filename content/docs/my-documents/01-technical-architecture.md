---
title: Technical Architecture
description: Complete technical architecture guide for the Hugo documentation system with reusable GitHub Actions
weight: 01
categories: [documentation, architecture]
tags: [hugo, github-actions, docsy, architecture, ai-generated]
creationDate: "2026-02-18"
lastUpdated: "2026-02-22"
version: "1.0"
---

## 1. Overview

The `my-documents` repository provides a **reusable GitHub Action** for building and deploying Hugo-based documentation
sites using the Docsy theme. This architecture enables multiple documentation repositories to share common
configurations, layouts, and assets while maintaining their independence.

### 1.1. Key Features

- **Reusable GitHub Action**: Single workflow definition used across multiple repositories
- **Hugo Go Modules**: Share layouts, assets, and configurations without file copying
- **No Authentication Complexity**: Uses standard `GITHUB_TOKEN` (no GitHub Apps or PATs required)
- **Independent Deployments**: Each repository controls its own build and deployment
- **Shared Theme Consistency**: All sites use the same Docsy theme with consistent styling
- **SEO Optimized**: Built-in structured data, meta tags, and sitemap generation

### 1.2. Managed Documentation Sites

| Site                 | Repository                      | Live URL                                             |
| -------------------- | ------------------------------- | ---------------------------------------------------- |
| My Documents         | fchastanet/my-documents         | <https://fchastanet.github.io/my-documents/>         |
| Bash Compiler        | fchastanet/bash-compiler        | <https://fchastanet.github.io/bash-compiler/>        |
| Bash Tools           | fchastanet/bash-tools           | <https://fchastanet.github.io/bash-tools/>           |
| Bash Tools Framework | fchastanet/bash-tools-framework | <https://fchastanet.github.io/bash-tools-framework/> |
| Bash Dev Env         | fchastanet/bash-dev-env         | <https://fchastanet.github.io/bash-dev-env/>         |

## 2. Building Locally

### 2.1. Prerequisites

Install the required tools:

- **Hugo Extended** v0.155.3 or higher (with Go support)
- **Go** 1.24 or higher
- **Git**

### 2.2. Quick Start

```bash
# Clone the repository
git clone https://github.com/fchastanet/my-documents.git
cd my-documents

# Download Hugo modules
hugo mod get -u

# Start local development server
hugo server -D

# Open browser to http://localhost:1313/my-documents/
```

The site will auto-reload when you edit content in `content/docs/`.

### 2.3. Building for Production

```bash
# Build optimized static site
hugo --minify

# Output is in public/ directory
ls -la public/
```

## 3. Reusable Action Architecture

### 3.1. Architecture Diagram

```text
┌─────────────────────────────────────────────────────────────────┐
│ my-documents Repository (Public)                                │
│                                                                 │
│  ├── .github/workflows/                                         │
│  │   ├── build-site-action.yml  ← Reusable action definition   │
│  │   └── build-site.yml          ← Own site build              │
│  │                                                              │
│  ├── configs/                                                   │
│  │   └── _base.yaml              ← Shared base configuration   │
│  │                                                              │
│  └── shared/                                                    │
│      ├── layouts/                ← Shared Hugo templates       │
│      ├── assets/                 ← Shared SCSS, CSS, JS        │
│      └── archetypes/             ← Content templates           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                           ▲
                           │ Hugo Go Module Import
                           │
        ┌──────────────────┼──────────────────┬──────────────────┐
        │                  │                  │                  │
        ▼                  ▼                  ▼                  ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐  ┌──────────────┐
│ bash-compiler │  │  bash-tools   │  │ bash-dev-env  │  │ Other Repos  │
│               │  │               │  │               │  │              │
│ go.mod        │  │ go.mod        │  │ go.mod        │  │ go.mod       │
│ hugo.yaml     │  │ hugo.yaml     │  │ hugo.yaml     │  │ hugo.yaml    │
│ content/      │  │ content/      │  │ content/      │  │ content/     │
│               │  │               │  │               │  │              │
│ .github/      │  │ .github/      │  │ .github/      │  │ .github/     │
│ workflows/    │  │ workflows/    │  │ workflows/    │  │ workflows/   │
│ build-site    │  │ build-site    │  │ build-site    │  │ build-site   │
│ .yml          │  │ .yml          │  │ .yml          │  │ .yml         │
│     │         │  │     │         │  │     │         │  │     │        │
│     └─────────┼──┼─────┼─────────┼──┼─────┼─────────┼──┼─────┘        │
│               │  │               │  │               │  │              │
└───────────────┘  └───────────────┘  └───────────────┘  └──────────────┘
        │                  │                  │                  │
        └──────────────────┴──────────────────┴──────────────────┘
                           │
                           │ Calls reusable action
                           ▼
              fchastanet/my-documents/
              .github/workflows/build-site-action.yml
                           │
                           ▼
              ┌────────────────────────┐
              │ 1. Checkout repo       │
              │ 2. Setup Hugo          │
              │ 3. Setup Go            │
              │ 4. Download modules    │
              │ 5. Build with Hugo     │
              │ 6. Deploy to Pages     │
              └────────────────────────┘
```

### 3.2. How It Works

The reusable action architecture follows this workflow:

1. **Developer pushes content** to a documentation repository (e.g., `bash-compiler`)
2. **GitHub Actions triggers** the `build-site.yml` workflow in that repository
3. **Workflow calls** `my-documents/.github/workflows/build-site-action.yml` (reusable action)
4. **Hugo downloads modules** including `my-documents` for shared resources
5. **Hugo builds site** using merged configuration (base + site-specific overrides)
6. **GitHub Pages deploys** the static site from the build artifact

### 3.3. Key Benefits

- **Zero Authentication Setup**: No GitHub Apps, deploy keys, or PAT tokens required
- **Independent Control**: Each repository owns its build and deployment
- **Shared Consistency**: All sites use the same theme, layouts, and styling
- **Easy Maintenance**: Update reusable action once, all sites benefit
- **Fast Builds**: Parallel execution across repositories (~30-60s per site)
- **Simple Testing**: Test locally with standard `hugo server` command

## 4. Creating a New Documentation Site

### 4.1. Prerequisites

Before creating a new documentation site, ensure you have:

- [ ] Admin access to create a new repository or use existing repository
- [ ] Basic understanding of Hugo and Markdown
- [ ] Hugo Extended and Go installed locally for testing

### 4.2. Step-by-Step Guide

#### 4.2.1. Create Content Structure

Create the standard Hugo directory structure in your repository:

```bash
# Create required directories
mkdir -p content/docs
mkdir -p static

# Create homepage
cat > content/_index.md << 'EOF'
---
title: My Project Documentation
description: Welcome to My Project documentation
---

# Welcome to My Project

This is the documentation homepage.
EOF

# Create first documentation page
cat > content/docs/_index.md << 'EOF'
---
title: Documentation
linkTitle: Docs
weight: 20
menu:
  main:
    weight: 20
---

# Documentation

Welcome to the documentation section.
EOF
```

#### 4.2.2. Add go.mod for Hugo Modules

Create `go.mod` in the repository root:

```go
module github.com/YOUR-USERNAME/YOUR-REPO

go 1.24

require (
 github.com/google/docsy v0.11.0 // indirect
 github.com/google/docsy/dependencies v0.7.2 // indirect
 github.com/fchastanet/my-documents master // indirect
)
```

Replace `YOUR-USERNAME/YOUR-REPO` with your actual repository path.

#### 4.2.3. Create hugo.yaml with Base Import

Create `hugo.yaml` in the repository root:

```yaml
# Import base configuration from my-documents
imports:
  - path: github.com/fchastanet/my-documents/configs/_base.yaml

# Site-specific overrides
baseURL: https://YOUR-USERNAME.github.io/YOUR-REPO
title: Your Project Documentation
languageCode: en-us

# Module configuration
module:
  # Import my-documents for shared resources
  imports:
    - path: github.com/fchastanet/my-documents
      mounts:
        # Mount shared layouts
        - source: shared/layouts
          target: layouts
        # Mount shared assets
        - source: shared/assets
          target: assets
        # Mount shared archetypes
        - source: shared/archetypes
          target: archetypes
    - path: github.com/google/docsy
    - path: github.com/google/docsy/dependencies

# Site-specific parameters
params:
  description: "Documentation for Your Project"

  # Customize theme colors
  ui:
    navbar_bg_color: "#007bff"  # Blue - choose your color
    sidebar_menu_compact: false

  # Repository configuration
  github_repo: https://github.com/YOUR-USERNAME/YOUR-REPO
  github_branch: master

  # Enable search
  offlineSearch: true
```

Replace placeholders:

- `YOUR-USERNAME` with your GitHub username
- `YOUR-REPO` with your repository name
- Adjust `navbar_bg_color` for your preferred theme color

#### 4.2.4. Add build-site.yml Workflow

Create `.github/workflows/build-site.yml`:

```yaml
name: Build and Deploy Documentation

on:
  push:
    branches: [master]
    paths:
      - 'content/**'
      - 'static/**'
      - 'hugo.yaml'
      - 'go.mod'
      - '.github/workflows/build-site.yml'
  workflow_dispatch:

# Required permissions for GitHub Pages deployment
permissions:
  contents: read
  pages: write
  id-token: write

# Prevent concurrent deployments
concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true

jobs:
  build-deploy:
    name: Build and Deploy
    uses: fchastanet/my-documents/.github/workflows/build-site-action.yml@master
    with:
      site-name: 'YOUR-REPO'
      base-url: 'https://YOUR-USERNAME.github.io/YOUR-REPO'
      checkout-repo: 'YOUR-USERNAME/YOUR-REPO'
    permissions:
      contents: read
      pages: write
      id-token: write
```

Replace:

- `YOUR-USERNAME` with your GitHub username
- `YOUR-REPO` with your repository name

**Important**: Ensure the workflow file has Unix line endings (LF), not Windows (CRLF).

#### 4.2.5. Configure GitHub Pages

In your repository settings:

1. Navigate to **Settings** → **Pages**
2. Under **Source**, select **GitHub Actions**
3. Click **Save**

{{% alert title="Note" color="info" %}}
With GitHub Actions as the source, Pages will deploy from workflow artifacts automatically. You do NOT need to
select a branch like `gh-pages`.
{{% /alert %}}

#### 4.2.6. Test and Deploy

**Test locally first:**

```bash
# Download modules
hugo mod get -u

# Start development server
hugo server -D

# Verify site at http://localhost:1313/
```

**Deploy to GitHub Pages:**

```bash
# Commit all files
git add .
git commit -m "Add Hugo documentation site"

# Push to trigger workflow
git push origin master
```

**Monitor deployment:**

1. Go to **Actions** tab in your repository
2. Watch the "Build and Deploy Documentation" workflow
3. Once complete (green checkmark), visit your site at `https://YOUR-USERNAME.github.io/YOUR-REPO`

### 4.3. Post-Creation Checklist

After creating your site, verify:

- [ ] Hugo builds locally without errors (`hugo --minify`)
- [ ] Development server runs (`hugo server -D`)
- [ ] All pages render correctly
- [ ] Navigation menu shows correct structure
- [ ] Search works (if enabled)
- [ ] GitHub Actions workflow completes successfully
- [ ] Site deploys to GitHub Pages
- [ ] All links work on live site
- [ ] Mobile view looks correct
- [ ] Theme colors match expectations

## 5. GitHub Configuration

### 5.1. GitHub Pages Settings

**Required Configuration:**

1. **Source**: GitHub Actions (NOT a branch)
2. **Custom Domain**: Optional
3. **Enforce HTTPS**: Recommended (enabled by default)

**Why GitHub Actions Source?**

Using GitHub Actions as the Pages source allows workflows to deploy directly using the `actions/deploy-pages` action.
This is simpler than pushing to a `gh-pages` branch and more secure.

### 5.2. Workflow Permissions

Your `build-site.yml` workflow requires these permissions:

```yaml
permissions:
  contents: read      # Read repository content
  pages: write        # Deploy to GitHub Pages
  id-token: write     # OIDC token for deployment
```

These permissions are:

- **Scoped to the workflow**: Only this workflow has these permissions
- **Automatic**: No manual configuration required
- **Secure**: Uses GitHub's OIDC authentication

### 5.3. No Secrets Required

Unlike traditional approaches, this architecture requires **zero secrets**:

- ❌ No GitHub App credentials
- ❌ No Personal Access Tokens (PAT)
- ❌ No Deploy Keys
- ✅ Standard `GITHUB_TOKEN` provided automatically

The workflow uses GitHub's built-in authentication, making setup simple and secure.

## 6. Hugo Configuration Details

### 6.1. go.mod Structure

The `go.mod` file declares Hugo module dependencies:

```go
module github.com/fchastanet/bash-compiler

go 1.24

require (
 github.com/google/docsy v0.11.0 // indirect
 github.com/google/docsy/dependencies v0.7.2 // indirect
 github.com/fchastanet/my-documents master // indirect
)
```

**Key Components:**

- **Module name**: Must match your repository path
- **Go version**: 1.24 or higher recommended
- **Docsy theme**: Version 0.11.0 (update as needed)
- **Docsy dependencies**: Bootstrap, Font Awesome, etc.
- **my-documents**: Provides shared layouts and assets

**Updating Modules:**

```bash
# Update all modules to latest versions
hugo mod get -u

# Update specific module
hugo mod get -u github.com/google/docsy

# Tidy module dependencies
hugo mod tidy
```

### 6.2. hugo.yaml Structure

The `hugo.yaml` configuration file has two main parts:

#### 6.2.1. Imports Section

```yaml
# Import base configuration from my-documents
imports:
  - path: github.com/fchastanet/my-documents/configs/_base.yaml
```

This imports shared configuration including:

- Hugo modules setup
- Markup and syntax highlighting
- Output formats (HTML, RSS, sitemap)
- Default theme parameters
- Language and i18n settings

#### 6.2.2. Site-Specific Configuration

Override base settings for your site:

```yaml
baseURL: https://fchastanet.github.io/bash-compiler
title: Bash Compiler Documentation
languageCode: en-us

module:
  imports:
    - path: github.com/fchastanet/my-documents
      mounts:
        - source: shared/layouts
          target: layouts
        - source: shared/assets
          target: assets
        - source: shared/archetypes
          target: archetypes
    - path: github.com/google/docsy
    - path: github.com/google/docsy/dependencies

params:
  description: "Documentation for Bash Compiler"
  ui:
    navbar_bg_color: "#007bff"
  github_repo: https://github.com/fchastanet/bash-compiler
  offlineSearch: true
```

### 6.3. Configuration Inheritance

Hugo merges configurations in this order:

1. **Base configuration** (`_base.yaml` from my-documents)
2. **Site-specific overrides** (your `hugo.yaml`)

**Merge Behavior:**

- **Scalar values**: Site-specific overrides base
- **Objects**: Deep merge (keys combined)
- **Arrays**: Site-specific replaces base entirely

**Example:**

```yaml
# Base (_base.yaml)
params:
  ui:
    showLightDarkModeMenu: true
    navbar_bg_color: "#563d7c"
  copyright: "My Documents"

# Site-specific (hugo.yaml)
params:
  ui:
    navbar_bg_color: "#007bff"
  copyright: "Bash Compiler"

# Result (merged)
params:
  ui:
    showLightDarkModeMenu: true    # From base
    navbar_bg_color: "#007bff"     # Overridden
  copyright: "Bash Compiler"       # Overridden
```

### 6.4. Site-Specific Overrides

Common parameters to override per site:

**Required:**

```yaml
baseURL: https://YOUR-USER.github.io/YOUR-REPO
title: Your Site Title
params:
  description: "Your site description"
  github_repo: https://github.com/YOUR-USER/YOUR-REPO
```

**Optional Theme Customization:**

```yaml
params:
  ui:
    navbar_bg_color: "#007bff"      # Navbar color
    sidebar_menu_compact: false      # Sidebar style
    navbar_logo: true                # Show logo in navbar

  links:
    user:
      - name: GitHub
        url: https://github.com/YOUR-USER/YOUR-REPO
        icon: fab fa-github
```

**Navigation Menu:**

```yaml
menu:
  main:
    - name: Documentation
      url: /docs/
      weight: 10
    - name: Blog
      url: /blog/
      weight: 20
```

## 7. Workflow Configuration

### 7.1. build-site.yml Structure

The `build-site.yml` workflow in each repository calls the reusable action:

```yaml
name: Build and Deploy Documentation

on:
  push:
    branches: [master]
    paths:
      - 'content/**'
      - 'static/**'
      - 'hugo.yaml'
      - 'go.mod'
      - '.github/workflows/build-site.yml'
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true

jobs:
  build-deploy:
    name: Build and Deploy
    uses: fchastanet/my-documents/.github/workflows/build-site-action.yml@master
    with:
      site-name: 'bash-compiler'
      base-url: 'https://fchastanet.github.io/bash-compiler'
      checkout-repo: 'fchastanet/bash-compiler'
    permissions:
      contents: read
      pages: write
      id-token: write
```

### 7.2. Calling the Reusable Action

The `uses` keyword calls the reusable action:

```yaml
uses: fchastanet/my-documents/.github/workflows/build-site-action.yml@master
```

**Format:** `OWNER/REPO/.github/workflows/WORKFLOW.yml@REF`

- **OWNER/REPO**: `fchastanet/my-documents` (the provider repository)
- **WORKFLOW**: `build-site-action.yml` (the reusable workflow file)
- **REF**: `master` (or specific tag/commit for stability)

### 7.3. Required Parameters

These parameters must be provided with `with`:

```yaml
with:
  site-name: 'bash-compiler'
  base-url: 'https://fchastanet.github.io/bash-compiler'
  checkout-repo: 'fchastanet/bash-compiler'
```

**Parameter Details:**

- **site-name**: Identifier for the site (used in artifacts and jobs)
- **base-url**: Full base URL where site will be deployed
- **checkout-repo**: Repository to checkout (format: `owner/repo`)

### 7.4. Optional Parameters

The reusable action may support additional parameters:

```yaml
with:
  hugo-version: '0.155.3'         # Default: latest
  go-version: '1.24'              # Default: 1.24
  extended: true                  # Default: true (Hugo Extended)
  working-directory: '.'          # Default: repository root
```

Check the reusable action definition for all available parameters.

### 7.5. Triggers Configuration

**Trigger on Content Changes:**

```yaml
on:
  push:
    branches: [master]
    paths:
      - 'content/**'
      - 'static/**'
      - 'hugo.yaml'
      - 'go.mod'
```

This triggers the workflow only when documentation-related files change, saving CI minutes.

**Trigger Manually:**

```yaml
on:
  workflow_dispatch:
```

Allows manual workflow runs from the GitHub Actions UI.

**Trigger on Schedule:**

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday at midnight UTC
```

Useful for rebuilding with updated dependencies.

### 7.6. Permissions Details

**Why These Permissions?**

```yaml
permissions:
  contents: read      # Clone repository and read content
  pages: write        # Upload artifact and deploy to Pages
  id-token: write     # Generate OIDC token for deployment
```

**Scope:**

- Permissions apply only to this workflow
- Defined at both workflow and job level for clarity
- More restrictive than repository-wide settings

**Security Note:**

Never grant `contents: write` unless absolutely necessary. The reusable action only needs `read` access.

## 8. Shared Resources Access

### 8.1. Hugo Go Modules Setup

Hugo modules enable sharing resources across repositories without file copying.

**Module Declaration (go.mod):**

```go
require (
 github.com/fchastanet/my-documents master // indirect
)
```

**Download Modules:**

```bash
# Download all declared modules
hugo mod get -u

# Verify modules downloaded
hugo mod graph
```

### 8.2. Accessing Layouts from my-documents

**Module Mount Configuration:**

```yaml
module:
  imports:
    - path: github.com/fchastanet/my-documents
      mounts:
        - source: shared/layouts
          target: layouts
```

**Available Layouts:**

```text
shared/layouts/
├── partials/
│   └── hooks/
│       └── head-end.html         # SEO meta tags, JSON-LD
├── shortcodes/
│   └── custom-shortcode.html     # Custom shortcodes
└── _default/
    └── baseof.html               # Optional: base template override
```

**Using Shared Partials:**

```html
<!-- In your custom layout -->
{{ partial "hooks/head-end.html" . }}
```

**Override Priority:**

1. Local `layouts/` directory (highest priority)
2. Mounted `shared/layouts/` from my-documents
3. Docsy theme layouts (lowest priority)

### 8.3. Accessing Assets from my-documents

**Module Mount Configuration:**

```yaml
module:
  imports:
    - path: github.com/fchastanet/my-documents
      mounts:
        - source: shared/assets
          target: assets
```

**Available Assets:**

```text
shared/assets/
└── scss/
    └── _variables_project.scss   # SCSS variables
```

**Using Shared SCSS:**

```scss
// Auto-imported by Docsy
// Defines custom variables used across all sites
$primary: #007bff;
$secondary: #6c757d;
```

**Override Site-Specific Styles:**

Create `assets/scss/_variables_project.scss` in your repository:

```scss
// Override specific variables
$primary: #ff6600;  // Orange theme

// Import base variables for other defaults
@import "shared/scss/variables_project";
```

### 8.4. Accessing Archetypes from my-documents

**Module Mount Configuration:**

```yaml
module:
  imports:
    - path: github.com/fchastanet/my-documents
      mounts:
        - source: shared/archetypes
          target: archetypes
```

**Available Archetypes:**

```text
shared/archetypes/
├── default.md       # Default content template
└── docs.md          # Documentation page template
```

**Using Archetypes:**

```bash
# Create new page using docs archetype
hugo new content/docs/guide.md

# Uses shared/archetypes/docs.md template
```

**Archetype Example (docs.md):**

```markdown
---
title: "{{ replace .Name "-" " " | title }}"
description: ""
weight: 10
categories: []
tags: []
---

## 9. Overview

Brief overview of this topic.

## 10. Details

Detailed content here.
```

### 10.1. Module Mounts Configuration

**Complete mounts example:**

```yaml
module:
  imports:
    # Mount my-documents shared resources
    - path: github.com/fchastanet/my-documents
      mounts:
        - source: shared/layouts
          target: layouts
        - source: shared/assets
          target: assets
        - source: shared/archetypes
          target: archetypes

    # Mount Docsy theme
    - path: github.com/google/docsy
      disable: false

    # Mount Docsy dependencies (Bootstrap, etc.)
    - path: github.com/google/docsy/dependencies
      disable: false
```

**Mount Options:**

- **source**: Path in the module repository
- **target**: Where to mount in your site
- **disable**: Set to `true` to temporarily disable

**Debugging Mounts:**

```bash
# Show module dependency graph
hugo mod graph

# Verify mounts configuration
hugo config mounts
```

## 11. Troubleshooting

### 11.1. Workflow Not Running

**Problem**: Workflow doesn't trigger on push

**Solutions:**

1. **Check file paths in trigger:**

   ```yaml
   on:
     push:
       paths:
         - 'content/**'
         - 'static/**'
         - 'hugo.yaml'
   ```

   Ensure changed files match these patterns.

2. **Verify branch name:**

   ```yaml
   on:
     push:
       branches: [master]  # Check your default branch name
   ```

3. **Check workflow syntax:**

   ```bash
   # Validate YAML syntax
   yamllint .github/workflows/build-site.yml
   ```

4. **Permissions issue**: Ensure Actions are enabled in repository settings:
   - Settings → Actions → General → "Allow all actions and reusable workflows"

### 11.2. Hugo Build Failures

**Problem**: Hugo build fails with errors

**Common Causes and Solutions:**

#### 11.2.1. Missing Modules

```text
Error: module "github.com/fchastanet/my-documents" not found
```

**Solution:**

```bash
# Ensure module declared in go.mod
hugo mod get -u

# Verify modules
hugo mod graph
```

#### 11.2.2. Configuration Errors

```text
Error: failed to unmarshal YAML
```

**Solution:**

```bash
# Validate YAML syntax
yamllint hugo.yaml

# Check Hugo config
hugo config
```

#### 11.2.3. Front Matter Errors

```text
Error: invalid front matter
```

**Solution:**

```markdown
<!-- Ensure front matter uses valid YAML -->
---
title: "My Page"
date: 2024-02-22
draft: false
---
```

#### 11.2.4. Template Errors

```text
Error: template: partial "missing.html" not found
```

**Solution:**

```bash
# Check partial exists in layouts/partials/
ls shared/layouts/partials/

# Verify module mounts
hugo config mounts
```

### 11.3. Hugo Modules Issues

**Problem**: Modules not updating or wrong version

**Solutions:**

1. **Clean module cache:**

   ```bash
   hugo mod clean
   hugo mod get -u
   ```

2. **Verify module versions:**

   ```bash
   # Show dependency graph
   hugo mod graph

   # Check go.sum for versions
   cat go.sum
   ```

3. **Force module update:**

   ```bash
   # Remove go.sum and rebuild
   rm go.sum
   hugo mod get -u
   hugo mod tidy
   ```

4. **Check module path:**

   ```yaml
   # Ensure correct repository path
   imports:
     - path: github.com/fchastanet/my-documents
   ```

### 11.4. Deployment Failures

**Problem**: Build succeeds but deployment fails

**Solutions:**

1. **Check Pages source:**
   - Settings → Pages → Source must be "GitHub Actions"

2. **Verify permissions:**

   ```yaml
   permissions:
     contents: read
     pages: write
     id-token: write
   ```

3. **Check deployment logs:**
   - Actions tab → Click workflow run → Expand "Deploy to GitHub Pages" step

4. **Concurrency conflict:**

   ```yaml
   concurrency:
     group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
     cancel-in-progress: true  # Cancel in-progress runs to ensure only the latest commit is deployed
   ```

5. **Artifact upload size:**

   ```bash
   # Check public/ directory size
   du -sh public/

   # GitHub has 10GB limit per artifact
   # Optimize images and remove unnecessary files
   ```

### 11.5. Content and Link Issues

**Problem**: Broken links or missing pages

**Solutions:**

1. **Check relative links:**

   ```markdown
   <!-- Correct -->
   [Guide](/docs/guide/)

   <!-- Incorrect -->
   [Guide](docs/guide/)  <!-- Missing leading slash -->
   ```

2. **Verify baseURL:**

   ```yaml
   # Must match deployment URL exactly
   baseURL: https://username.github.io/repo-name
   ```

3. **Check content organization:**

   ```text
   content/
   └── en/
       ├── _index.md
       └── docs/
           ├── _index.md
           └── guide.md
   ```

4. **Front matter issues:**

   ```markdown
   ---
   title: "Guide"
   # Check for typos in keys
   linkTitle: "User Guide"
   weight: 10
   ---
   ```

5. **Test links locally:**

   ```bash
   hugo server -D
   # Check all links work at http://localhost:1313
   ```

### 11.6. Debugging Checklist

When troubleshooting, work through this checklist:

- [ ] **Local build succeeds**: `hugo --minify` completes without errors
- [ ] **Modules downloaded**: `hugo mod graph` shows correct dependencies
- [ ] **Configuration valid**: `hugo config` outputs without errors
- [ ] **Workflow syntax valid**: YAML linter passes
- [ ] **Permissions correct**: Workflow has `pages: write` permission
- [ ] **Pages source configured**: GitHub Pages source is "GitHub Actions"
- [ ] **Actions enabled**: Repository allows GitHub Actions
- [ ] **Branch correct**: Workflow triggers on correct branch
- [ ] **Paths correct**: Changed files match workflow path filters
- [ ] **Artifacts created**: Workflow creates and uploads artifact
- [ ] **Deployment job runs**: Separate deployment job executes
- [ ] **Content accessible**: Files in `content/` directory render
- [ ] **Links work**: Internal navigation functions correctly

**Verbose Build Output:**

```bash
# Local debugging with verbose output
hugo --minify --verbose --debug

# Check Hugo environment
hugo env
```

**Check GitHub Actions Logs:**

1. Go to repository → Actions tab
2. Click failing workflow run
3. Expand each step to see detailed output
4. Look for ERROR or WARN messages

## 12. Advanced Topics

### 12.1. Per-Site Theme Customization

Each site can customize the Docsy theme while maintaining shared base styles.

**Color Customization:**

```yaml
# hugo.yaml
params:
  ui:
    navbar_bg_color: "#007bff"     # Blue navbar
    sidebar_bg_color: "#f8f9fa"    # Light gray sidebar
    navbar_text_color: "#ffffff"   # White text
```

**Custom SCSS Variables:**

Create `assets/scss/_variables_project.scss` in your repository:

```scss
// Override primary color
$primary: #ff6600;
$secondary: #6c757d;

// Custom navbar height
$navbar-height: 70px;

// Import base variables for other defaults
@import "shared/scss/variables_project";
```

**Custom Layouts:**

Override specific templates by creating them locally:

```text
layouts/
├── _default/
│   └── single.html          # Custom single page layout
├── partials/
│   └── navbar.html          # Custom navbar
└── shortcodes/
    └── callout.html         # Custom shortcode
```

**Priority Order:**

1. Local `layouts/` (highest)
2. Mounted `shared/layouts/` from my-documents
3. Docsy theme layouts (lowest)

### 12.2. SEO Metadata

Shared SEO features are provided via `shared/layouts/partials/hooks/head-end.html`:

**Automatic SEO Tags:**

- Open Graph meta tags
- Twitter Card tags
- JSON-LD structured data
- Canonical URLs
- Sitemap generation

**Configure per Page:**

```markdown
---
title: "My Guide"
description: "Comprehensive guide to using the tool"
images: ["/images/guide-preview.png"]
---
```

**Site-Wide SEO:**

```yaml
# hugo.yaml
params:
  description: "Default site description"
  images: ["/images/site-preview.png"]

  # Social links for structured data
  github_repo: https://github.com/user/repo

  # Google Analytics (optional)
  google_analytics: "G-XXXXXXXXXX"
```

**Verify SEO:**

```bash
# Check generated meta tags
hugo server -D
curl http://localhost:1313/page/ | grep -A5 "og:"
```

### 12.3. Menu Customization

**Main Menu Configuration:**

```yaml
# hugo.yaml
menu:
  main:
    - name: Documentation
      url: /docs/
      weight: 10
    - name: About
      url: /about/
      weight: 20
    - name: GitHub
      url: https://github.com/user/repo
      weight: 30
      pre: <i class='fab fa-github'></i>
```

**Per-Page Menu Entry:**

```markdown
---
title: "API Reference"
menu:
  main:
    name: "API"
    weight: 15
    parent: "Documentation"
---
```

**Sidebar Menu:**

The sidebar menu is automatically generated from content structure. Control it with:

```markdown
---
title: "Section"
weight: 10              # Order in menu
linkTitle: "Short Name" # Display name (optional)
---
```

**Disable Menu Item:**

```markdown
---
title: "Hidden Page"
menu:
  main:
    weight: 0
_build:
  list: false
  render: true
---
```

## 13. Contributing

### 13.1. How to Contribute to Reusable Action

The reusable action is defined in `my-documents/.github/workflows/build-site-action.yml`.

**Contributing Process:**

1. **Fork the repository:**

   ```bash
   gh repo fork fchastanet/my-documents --clone
   cd my-documents
   ```

2. **Create a feature branch:**

   ```bash
   git checkout -b feature/improve-action
   ```

3. **Make changes:**
   - Edit `.github/workflows/build-site-action.yml`
   - Update documentation if needed
   - Test changes thoroughly

4. **Commit using conventional commits:**

   ```bash
   git commit -m "feat(workflows): add support for custom Hugo version"
   ```

5. **Push and create PR:**

   ```bash
   git push origin feature/improve-action
   gh pr create --title "Add custom Hugo version support"
   ```

### 13.2. Testing Changes

**Test Reusable Action Changes:**

1. **Push changes to your fork:**

   ```bash
   git push origin feature/improve-action
   ```

2. **Update dependent repository to use your fork:**

   ```yaml
   # .github/workflows/build-site.yml
   jobs:
     build-deploy:
       uses: YOUR-USERNAME/my-documents/.github/workflows/build-site-action.yml@feature/improve-action
   ```

3. **Trigger workflow:**

   ```bash
   git commit --allow-empty -m "Test workflow"
   git push
   ```

4. **Verify results:**
   - Check Actions tab for workflow run
   - Ensure build and deployment succeed
   - Test deployed site

**Test Configuration Changes:**

```bash
# Test base configuration changes
cd my-documents
hugo server -D

# Test site-specific overrides
cd bash-compiler
hugo mod get -u
hugo server -D
```

**Test Shared Resources:**

```bash
# Add new shared layout
echo '<meta name="test" content="value">' > shared/layouts/partials/test.html

# Rebuild dependent site
cd ../bash-compiler
hugo mod clean
hugo mod get -u
hugo server -D

# Verify partial available
curl http://localhost:1313 | grep 'name="test"'
```

### 13.3. Best Practices

**Workflow Development:**

- **Test thoroughly**: Changes affect all dependent sites
- **Use semantic versioning**: Tag stable versions
- **Document parameters**: Add clear comments
- **Handle errors gracefully**: Add validation steps
- **Maintain backwards compatibility**: Don't break existing sites

**Configuration Updates:**

- **Test locally first**: Verify `hugo config` output
- **Check all sites**: Test impact on all dependent repositories
- **Document changes**: Update this documentation
- **Use minimal diffs**: Only change what's necessary
- **Validate YAML**: Use `yamllint` before committing

**Shared Resources:**

- **Keep layouts generic**: Avoid site-specific code
- **Document usage**: Add comments to complex partials
- **Version carefully**: Breaking changes require coordination
- **Test across sites**: Ensure compatibility with all sites
- **Optimize assets**: Minimize SCSS and JS files

**Communication:**

- **Open issues**: Discuss major changes before implementing
- **Tag maintainers**: Use `@mentions` for review requests
- **Document breaking changes**: Clearly mark in PR description
- **Update changelog**: Keep CHANGELOG.md up to date
- **Announce deployments**: Notify dependent site owners

## 14. CI/CD Workflows Reference

### 14.1. build-site-action.yml (Reusable)

**Location:** `my-documents/.github/workflows/build-site-action.yml`

**Purpose:** Reusable workflow called by dependent repositories to build and deploy Hugo sites.

**Inputs:**

```yaml
inputs:
  site-name:
    description: 'Name of the site being built'
    required: true
    type: string

  base-url:
    description: 'Base URL for the site'
    required: true
    type: string

  checkout-repo:
    description: 'Repository to checkout (owner/repo)'
    required: true
    type: string

  hugo-version:
    description: 'Hugo version to use'
    required: false
    type: string
    default: 'latest'

  go-version:
    description: 'Go version to use'
    required: false
    type: string
    default: '1.24'
```

**Steps:**

1. **Checkout repository**: Clones the calling repository
2. **Setup Hugo**: Installs Hugo Extended
3. **Setup Go**: Installs Go (required for Hugo modules)
4. **Download modules**: Runs `hugo mod get -u`
5. **Build site**: Runs `hugo --minify`
6. **Upload artifact**: Uploads `public/` directory
7. **Deploy to Pages**: Uses `actions/deploy-pages`

**Usage Example:**

```yaml
jobs:
  build-deploy:
    uses: fchastanet/my-documents/.github/workflows/build-site-action.yml@master
    with:
      site-name: 'bash-compiler'
      base-url: 'https://fchastanet.github.io/bash-compiler'
      checkout-repo: 'fchastanet/bash-compiler'
```

### 14.2. build-site.yml (my-documents Own)

**Location:** `my-documents/.github/workflows/build-site.yml`

**Purpose:** Builds and deploys the my-documents site itself (not a reusable workflow).

**Triggers:**

```yaml
on:
  push:
    branches: [master]
    paths:
      - 'content/**'
      - 'static/**'
      - 'shared/**'
      - 'configs/**'
      - 'hugo.yaml'
      - 'go.mod'
  workflow_dispatch:
```

**Calls:** The same `build-site-action.yml` reusable workflow

**Configuration:**

```yaml
jobs:
  build-deploy:
    uses: ./.github/workflows/build-site-action.yml
    with:
      site-name: 'my-documents'
      base-url: 'https://fchastanet.github.io/my-documents'
      checkout-repo: 'fchastanet/my-documents'
```

### 14.3. main.yml

**Location:** `my-documents/.github/workflows/main.yml`

**Purpose:** Runs pre-commit hooks and MegaLinter on the repository and deploy documentation if master branch is updated.

**Triggers:**

```yaml
on:
  push:
    branches: ['**']
  pull_request:
    branches: [master]
  workflow_dispatch:
```

**Steps:**

1. **Checkout code**: Clones repository with full history
2. **Setup Python**: Installs Python for pre-commit
3. **Install pre-commit**: Installs pre-commit tool
4. **Run pre-commit**: Executes all pre-commit hooks
5. **Run MegaLinter**: Runs comprehensive linting
6. **Upload reports**: Saves linter reports as artifacts
7. **Create auto-fix PR**: Optionally creates PR with fixes (if not "skip fix" in commit)

**Linters Run:**

- **Markdown**: mdformat, markdownlint
- **YAML**: yamllint, v8r
- **JSON**: jsonlint
- **Bash**: shellcheck, shfmt
- **Spelling**: cspell, codespell
- **Secrets**: gitleaks, secretlint

**Auto-fix Behavior:**

If linters make changes and commit message doesn't contain "skip fix", an auto-fix PR is created automatically.

## 15. Summary

This documentation system uses a modern, reusable GitHub Actions architecture that simplifies deployment and maintenance:

**Key Takeaways:**

- **No complex authentication**: Standard `GITHUB_TOKEN` only
- **Reusable action**: One workflow definition, multiple sites
- **Hugo modules**: Share resources without file copying
- **Independent control**: Each repo owns its deployment
- **Easy testing**: Standard Hugo commands work locally
- **Fast builds**: Parallel execution across repositories

**Getting Started:**

1. Create content structure in your repository
2. Add `go.mod`, `hugo.yaml`, and `build-site.yml`
3. Configure GitHub Pages to use "GitHub Actions" source
4. Push to trigger automatic build and deployment

**Next Steps:**

- Follow [Creating a New Documentation Site](#4-creating-a-new-documentation-site) for step-by-step setup
- Review [Hugo Configuration Details](#6-hugo-configuration-details) for customization options
- Check [Troubleshooting](#11-troubleshooting) if you encounter issues
- See [Contributing](#13-contributing) to improve the reusable action

For questions or issues, open an issue in the
[my-documents repository](https://github.com/fchastanet/my-documents/issues).
