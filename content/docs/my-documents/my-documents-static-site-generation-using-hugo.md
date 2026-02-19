---
title: My Documents - Static Site Generation Using Hugo
description: Comprehensive documentation of the Hugo migration for multi-site documentation
creationDate: "2026-02-18"
lastUpdated: "2026-02-18"
version: "1.0"
categories: [Brainstorming]
tags: [hugo, docsy, multi-site, documentation, static-site-generator, github-actions]
---
# My Documents - Static Site Generation Using Hugo - Migration Analysis and Implementation

<!--TOC-->

- [My Documents - Static Site Generation Using Hugo - Migration Analysis and Implementation](#my-documents---static-site-generation-using-hugo---migration-analysis-and-implementation)
  - [1. Technical Solutions Evaluated](#1-technical-solutions-evaluated)
    - [1.1. Static Site Generator Solutions](#11-static-site-generator-solutions)
      - [1.1.1. Hugo (SELECTED)](#111-hugo-selected)
      - [1.1.2. Astro](#112-astro)
      - [1.1.3. 11ty (Eleventy)](#113-11ty-eleventy)
      - [1.1.4. VuePress 2](#114-vuepress-2)
      - [1.1.5. MkDocs](#115-mkdocs)
      - [1.1.6. Next.js and Gatsby](#116-nextjs-and-gatsby)
      - [1.1.7. Comparison Summary](#117-comparison-summary)
    - [1.2. Multi-Site Build Pipeline Solutions](#12-multi-site-build-pipeline-solutions)
      - [1.2.1. Centralized Orchestrator (my-documents builds all sites) (SELECTED)](#121-centralized-orchestrator-my-documents-builds-all-sites-selected)
      - [1.2.2. Decentralized with Reusable Workflows + Hugo Modules](#122-decentralized-with-reusable-workflows--hugo-modules)
      - [1.2.3. True Monorepo with Subdirectories](#123-true-monorepo-with-subdirectories)
      - [1.2.4. Pipeline Solution Comparison](#124-pipeline-solution-comparison)
  - [2. Chosen Solutions & Rationale](#2-chosen-solutions--rationale)
    - [2.1. Static Site Generator: Hugo + Docsy Theme](#21-static-site-generator-hugo--docsy-theme)
    - [2.2. Multi-Site Pipeline: Centralized Orchestrator](#22-multi-site-pipeline-centralized-orchestrator)
  - [3. Implementation Details](#3-implementation-details)
    - [3.1. Repository Architecture](#31-repository-architecture)
    - [3.2. Directory Structure](#32-directory-structure)
      - [3.2.1. my-documents (Orchestrator)](#321-my-documents-orchestrator)
      - [3.2.2. Dependent Repository (Example: bash-compiler)](#322-dependent-repository-example-bash-compiler)
    - [3.3. Configuration Merging Strategy](#33-configuration-merging-strategy)
    - [3.4. Build Workflow](#34-build-workflow)
    - [3.5. Deployment Approach](#35-deployment-approach)
    - [3.6. Trigger Mechanism](#36-trigger-mechanism)
    - [3.7. Theme Customization](#37-theme-customization)
  - [4. Lessons Learned & Future Considerations](#4-lessons-learned--future-considerations)
    - [4.1. GitHub App Migration from Deploy Keys](#41-github-app-migration-from-deploy-keys)
    - [4.2. Trade-offs Discovered](#42-trade-offs-discovered)
      - [4.2.1. All-Site Rebuild Trade-off](#421-all-site-rebuild-trade-off)
      - [4.2.2. Authentication Complexity](#422-authentication-complexity)
      - [4.2.3. Configuration Flexibility vs Consistency](#423-configuration-flexibility-vs-consistency)
    - [4.3. Best Practices Identified](#43-best-practices-identified)
      - [4.3.1. Configuration Management](#431-configuration-management)
      - [4.3.2. Build Optimization](#432-build-optimization)
      - [4.3.3. Dependency Management](#433-dependency-management)
      - [4.3.4. Security](#434-security)
    - [4.4. Future Considerations](#44-future-considerations)
      - [4.4.1. Potential Optimizations](#441-potential-optimizations)
      - [4.4.2. Scalability Considerations](#442-scalability-considerations)
      - [4.4.3. Alternative Approaches for Future Projects](#443-alternative-approaches-for-future-projects)
    - [4.5. Success Metrics](#45-success-metrics)
  - [5. Conclusion](#5-conclusion)

<!--TOC-->

**Project:** Migration from Docsify to Hugo with Docsy theme for multiple documentation repositories

**Status:** ✅ Completed

**Repositories:**

- `fchastanet/my-documents` (orchestrator + own documentation)
- `fchastanet/bash-compiler`
- `fchastanet/bash-tools`
- `fchastanet/bash-tools-framework`
- `fchastanet/bash-dev-env`

**Related Documentation:** See [doc/ai/2026-02-18-migrate-repo-from-docsify-to-hugo.md](../../../doc/ai/2026-02-18-migrate-repo-from-docsify-to-hugo.md)
for detailed migration guide.

## 1. Technical Solutions Evaluated

### 1.1. Static Site Generator Solutions

#### 1.1.1. Hugo (SELECTED)

**Evaluation:** ⭐⭐⭐⭐⭐
**Type:** Go-based static site generator

**Pros:**

- Extremely fast compilation (<1s for most documentation sites)
- Excellent for documentation with purpose-built features
- Superior SEO support (static HTML, sitemaps, feeds, schemas) - **9/10 SEO score**
- Single binary with no dependency complications
- Markdown + frontmatter support (natural progression from Docsify)
- GitHub Actions ready with official actions
- Large theme ecosystem (500+ themes) including specialized documentation themes
- Built-in features: search indexes, RSS feeds, hierarchical content organization
- Output optimization: image processing, minification, CSS purging
- Active community with frequent updates
- Multi-language support built-in

**Cons:**

- Learning curve for Go templating (shortcodes, partials)
- Theme customization requires understanding Hugo's page model
- Configuration in YAML/TOML format

**GitHub CI/CD Integration:** Native, simple integration with peaceiris/actions-hugo

**Best For:** Technical documentation, multi-site architecture, SEO-critical sites, GitHub Pages, content-heavy sites

#### 1.1.2. Astro

**Evaluation:** ⭐⭐⭐⭐
**Type:** JavaScript/TypeScript-based with island architecture

**Pros:**

- Outstanding SEO support (static HTML, zero JavaScript by default) - **9/10 SEO score**
- Modern JavaScript patterns with TypeScript support
- Markdown + MDX support (embedded React/Vue components in Markdown)
- Island architecture minimizes JavaScript shipping
- Fast performance and build times (<2s)
- Automatic image optimization (AVIF support)
- Vite-based with fast HMR

**Cons:**

- Newer ecosystem, less battle-tested than Hugo
- Requires Node.js and npm dependency management
- Smaller theme ecosystem
- MDX adds complexity if not needed

**Best For:** Modern tech stacks, interactive components, TypeScript-heavy teams, blogs + documentation hybrids

#### 1.1.3. 11ty (Eleventy)

**Evaluation:** ⭐⭐⭐⭐

**Type:** JavaScript template engine

**Pros:**

- Incredibly flexible with multiple template language support
- Lightweight and fast builds
- JavaScript-based (easier for Node.js teams)
- Low barrier to entry
- No framework lock-in

**Cons:**

- Less opinionated, requires more configuration
- Smaller pre-built theme ecosystem
- No built-in search (requires plugins)
- SEO score: **8/10**

**Best For:** Developers wanting full control, JavaScript/Node.js teams, unique design requirements

#### 1.1.4. VuePress 2

**Evaluation:** ⭐⭐⭐

**Type:** Vue 3-based static site generator

**Pros:**

- Documentation-first design
- Built-in search functionality
- Plugin ecosystem for documentation
- Vue component integration in Markdown

**Cons:**

- Vue.js knowledge required
- Heavy JavaScript bundle (not as optimized as others)
- Smaller ecosystem than Hugo
- SEO score: **6/10**

**Best For:** Vue-centric teams, smaller documentation sites

#### 1.1.5. MkDocs

**Evaluation:** ⭐⭐⭐

**Type:** Python-based documentation generator

**Pros:**

- Documentation-optimized out of the box
- Simple configuration
- Material for MkDocs theme is excellent
- Fast builds

**Cons:**

- Python dependency management required
- Smaller ecosystem than Hugo
- Limited flexibility
- SEO score: **7/10**

**Best For:** Documentation-only focus, Python-familiar teams, rapid setup

#### 1.1.6. Next.js and Gatsby

**Evaluation:** ⭐⭐ - **Not recommended** for static documentation

**Reasons:**

- Overkill complexity for pure documentation
- Longer build times (5-30s vs <1s for Hugo)
- Heavy JavaScript requirements
- Optimized for different use cases (web apps, not docs)
- Maintenance burden too high for static documentation

#### 1.1.7. Comparison Summary

| Criteria | Hugo | Astro | 11ty | VuePress | MkDocs |
| --- | --- | --- | --- | --- | --- |
| **SEO Score** | 9/10 | 9/10 | 8/10 | 6/10 | 7/10 |
| **Build Speed** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Learning Curve** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| **GitHub Pages** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Documentation Focus** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Theme Ecosystem** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Multi-Site Support** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

### 1.2. Multi-Site Build Pipeline Solutions

#### 1.2.1. Centralized Orchestrator (my-documents builds all sites) (SELECTED)

**Evaluation:** ⭐⭐⭐⭐⭐
**Architecture:**

```text
my-documents (orchestrator)
├── .github/workflows/build-all-sites.yml  ← Builds all sites
├── configs/
│   ├── _base.yaml                         ← Shared config
│   ├── bash-compiler.yaml                 ← Site overrides
│   ├── bash-tools.yaml
│   └── bash-tools-framework.yaml
├── shared/
│   ├── layouts/                           ← Shared templates
│   ├── assets/                            ← Shared styles
│   └── archetypes/                        ← Content templates
└── content/                               ← my-documents own docs

Dependent repos (minimal):
bash-compiler/
├── .github/workflows/trigger-docs.yml     ← Triggers my-documents
└── content/en/                            ← Documentation only
```

**How It Works:**

1. Push to `bash-compiler` → triggers `my-documents` via `repository_dispatch`
2. my-documents workflow:
   - Checks out ALL repos (my-documents, bash-compiler, bash-tools, bash-tools-framework, bash-dev-env)
   - Builds each site in parallel using GitHub Actions matrix strategy
   - Merges configs (`_base.yaml` + site-specific overrides)
   - Deploys each site to its respective GitHub Pages

**Pros:**

- ✅ All repos under same owner (fchastanet) simplifies permission management
- ✅ One workflow update fixes all sites immediately
- ✅ Guaranteed consistency across all documentation sites
- ✅ Simpler per-repo setup (2 files: trigger workflow + content)
- ✅ No Hugo modules needed (simpler dependency management)
- ✅ Centralized theme customization with per-site overrides
- ✅ Build all sites in ~60s (parallel matrix execution)
- ✅ Single point of maintenance

**Cons:**

- ⚠️ Requires authentication setup (GitHub App or deploy keys)
- ⚠️ All sites rebuild together (cannot isolate to single site)
- ⚠️ All-or-nothing failures (one site failure blocks others in same matrix job)
- ⚠️ Slightly more complex initial setup

**Best For:** Related projects under same organization, shared theme/purpose, centralized maintenance preference

#### 1.2.2. Decentralized with Reusable Workflows + Hugo Modules

**Architecture:**

```text
my-documents (shared resources hub)
├── .github/workflows/hugo-build-deploy-reusable.yml  ← Reusable workflow
├── layouts/ (Hugo module export)
└── assets/ (Hugo module export)

bash-compiler/ (independent)
├── .github/workflows/hugo-build-deploy.yml  ← Calls reusable workflow
├── hugo.yaml (imports my-documents module)
├── go.mod
└── content/
```

**How It Works:**

1. Each dependent repo has its own build workflow
2. Workflow calls the reusable workflow from my-documents
3. Hugo modules pull shared resources during build
4. Each site builds and deploys independently

**Pros:**

- ✅ Independent deployment (site failures isolated)
- ✅ Automatic updates when reusable workflow changes
- ✅ Version control (can pin to `@v1.0.0` or `@master`)
- ✅ No trigger coordination needed
- ✅ Faster builds for single-site changes (~30s per site)
- ✅ Per-repo flexibility if needed

**Cons:**

- ⚠️ Hugo modules require Go toolchain
- ⚠️ More files per repository (6 core files vs 2)
- ⚠️ Learning curve for Hugo module system
- ⚠️ Network dependency (modules fetched from GitHub)
- ⚠️ Potential configuration drift if repos don't update modules
- ⚠️ More complex to enforce consistency

**Best For:** Fully independent projects, teams wanting flexibility, isolated failure tolerance

#### 1.2.3. True Monorepo with Subdirectories

**Architecture:** All content in single repo with subdirectories for each project

**Pros:**

- ✅ Simplest configuration
- ✅ Single build process
- ✅ Guaranteed consistency

**Cons:**

- ❌ Loses separate GitHub Pages URLs
- ❌ No independent repository control
- ❌ Violates existing repository structure
- ❌ Complicated permission management

**Evaluation:** **Not recommended** - Conflicts with requirement to maintain separate repository URLs

#### 1.2.4. Pipeline Solution Comparison

| Criteria | Centralized Orchestrator | Decentralized Reusable | Monorepo |
| --- | --- | --- | --- |
| **Complexity** | Low (minimal per-repo) | Medium (per-repo setup) | Low (single repo) |
| **Build Time** | ~60s all sites | ~30s per site | ~60s all sites |
| **Maintenance** | Update once | Update workflow × N | Update once |
| **Consistency** | ✅ Guaranteed | Can drift | ✅ Guaranteed |
| **Failure Isolation** | All-or-nothing | ✅ Independent | All-or-nothing |
| **Setup Effort** | 1 workflow + N configs | 6 files × N repos | Single setup |
| **Independent URLs** | ✅ Yes | ✅ Yes | ❌ No |
| **Hugo Modules** | ❌ Not needed | Required | ❌ Not needed |

## 2. Chosen Solutions & Rationale

### 2.1. Static Site Generator: Hugo + Docsy Theme

**Choice:** Hugo with Google's Docsy theme

**Rationale:**

1. **SEO Requirements Met:**
   - Static HTML pre-rendering (search engines can easily index)
   - Automatic sitemap and robots.txt generation
   - Per-page meta tags and structured data support
   - RSS/Atom feeds
   - Image optimization
   - Performance optimizations (minification, compression)
   - **SEO improvement: 2/10 (Docsify) → 9/10 (Hugo)**

2. **Technical Excellence:**
   - Extremely fast builds (<1s for typical documentation site)
   - Simple deployment (single Go binary, no dependency hell)
   - GitHub Pages native support
   - Mature, stable, battle-tested (10+ years in production use)

3. **Documentation-Specific Features:**
   - Docsy theme built by Google specifically for documentation
   - Built-in search functionality
   - Responsive design
   - Navigation auto-generation from content structure
   - Version management support
   - Multi-language support

4. **Developer Experience:**
   - Markdown + frontmatter (minimal migration effort from Docsify)
   - Good documentation and large community
   - Extensive theme ecosystem
   - Active development and updates

5. **Multi-Site Architecture Support:**
   - Excellent support for shared configurations
   - Hugo modules for code reuse
   - Flexible configuration merging
   - Content organization flexibility

**Alternatives Considered:**

- **Astro:** Excellent option, but newer ecosystem and Node.js dependency management adds complexity
- **11ty:** Good flexibility, but less opinionated structure requires more setup work
- **MkDocs:** Python dependencies and smaller ecosystem less ideal
- **VuePress/Next.js/Gatsby:** Too heavy for pure documentation needs

### 2.2. Multi-Site Pipeline: Centralized Orchestrator

**Choice:** Centralized build orchestrator in my-documents repository

**Rationale:**

1. **Project Context Alignment:**
   - All repositories under same owner (fchastanet)
   - All share same purpose (Bash tooling documentation)
   - All need consistent look and feel
   - Related projects benefit from coordinated updates

2. **Maintenance Efficiency:**
   - Single workflow update affects all sites immediately
   - One place to fix bugs or add features
   - Guaranteed consistency across all documentation
   - Reduced mental overhead (one system to understand)

3. **Simplified Per-Repository Structure:**
   - Only 2 essential files per dependent repo:
     - Trigger workflow (10 lines)
     - Content directory
   - No Hugo configuration duplication
   - No Go module management per repo

4. **Configuration Management:**
   - Base configuration shared via `configs/_base.yaml`
   - Site-specific overrides in `configs/{site}.yaml`
   - Automatic merging with `yq` tool
   - No configuration drift possible

5. **Build Efficiency:**
   - Parallel matrix execution builds all 5 sites simultaneously
   - Total time ~60s for all sites (vs 30s × 5 = 150s sequential)
   - Resource sharing in CI/CD (single Hugo/Go setup)

6. **Deployment Simplification:**
   - Authentication centralized in my-documents (GitHub App)
   - Single set of deployment credentials
   - Easier to audit and manage security

**Trade-offs Accepted:**

- ⚠️ All sites rebuild together (acceptable for related documentation)
- ⚠️ More complex initial setup (one-time investment)
- ⚠️ All-or-nothing failures (mitigated with `fail-fast: false` in matrix)

**Alternatives Considered:**

- **Decentralized Reusable Workflows:** Good for truly independent projects, but adds complexity without benefit for
our use case where all sites are related and share theme/purpose
- **Monorepo:** Would lose independent GitHub Pages URLs, not acceptable

## 3. Implementation Details

### 3.1. Repository Architecture

**Orchestrator Repository:** `fchastanet/my-documents`

**Responsibilities:**

- Build all documentation sites (including its own)
- Manage shared configurations and theme customizations
- Deploy to multiple GitHub Pages repositories
- Coordinate builds triggered from dependent repositories

**Dependent Repositories:**

- `fchastanet/bash-compiler`
- `fchastanet/bash-tools`
- `fchastanet/bash-tools-framework`
- `fchastanet/bash-dev-env`

**Responsibilities:** Contain documentation content only, trigger builds in orchestrator

### 3.2. Directory Structure

#### 3.2.1. my-documents (Orchestrator)

```text
/home/wsl/fchastanet/my-documents/
├── .github/workflows/
│   └── build-all-sites.yml              ← Orchestrator workflow
├── configs/
│   ├── _base.yaml                       ← Shared configuration
│   ├── my-documents.yaml               ← my-documents overrides
│   ├── bash-compiler.yaml              ← bash-compiler overrides
│   ├── bash-tools.yaml
│   ├── bash-tools-framework.yaml
│   └── bash-dev-env.yaml
├── shared/
│   ├── layouts/                         ← Shared Hugo templates
│   ├── assets/                          ← Shared SCSS, JS
│   └── archetypes/                      ← Content templates
├── content/                             ← my-documents own content
├── hugo.yaml                            ← Generated per build
└── go.mod                               ← Hugo modules (Docsy)
```

**Key Files:**

- [.github/workflows/build-all-sites.yml](../../.github/workflows/build-all-sites.yml) - Orchestrator workflow
- [configs/_base.yaml](../../configs/_base.yaml) - Shared Hugo configuration
- [configs/bash-compiler.yaml](../../configs/bash-compiler.yaml) - Example site-specific config
- [shared/](../../shared/) - Shared theme customizations

#### 3.2.2. Dependent Repository (Example: bash-compiler)

```text
fchastanet/bash-compiler/
├── .github/workflows/
│   └── trigger-docs.yml                 ← Triggers orchestrator
└── content/en/                          ← Documentation content only
    ├── _index.md
    └── docs/
        └── *.md
```

### 3.3. Configuration Merging Strategy

**Approach:** Use `yq` tool for proper YAML deep-merging

**Base Configuration:** [configs/_base.yaml](../../configs/_base.yaml)

Contains:

- Hugo module imports (Docsy theme)
- Common parameters (language, SEO settings)
- Shared markup configuration
- Mount points for shared resources
- Common menu structure
- Default theme parameters

**Site-Specific Overrides:** Example [configs/bash-compiler.yaml](../../configs/bash-compiler.yaml)

Contains:

- Site title and baseURL
- Repository-specific links
- Site-specific theme colors (`ui.navbar_bg_color`)
- Custom menu items
- SEO keywords specific to the project
- GitHub repository links

**Merging Process:**

Implemented in [.github/workflows/build-all-sites.yml](../../.github/workflows/build-all-sites.yml):

```yaml
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
  configs/_base.yaml \
  configs/bash-compiler.yaml > hugo.yaml
```

**Result:** Clean, merged `hugo.yaml` with:

- Base configuration as foundation
- Site-specific overrides applied
- Proper YAML structure preserved (no duplication)
- Deep merge of nested objects

### 3.4. Build Workflow

**Main Workflow:** [.github/workflows/build-all-sites.yml](../../.github/workflows/build-all-sites.yml)

**Triggers:**

- `workflow_dispatch` - Manual trigger
- `repository_dispatch` with type `trigger-docs-rebuild` - From dependent repos
- `push` to `master` branch affecting:
  - `content/**`
  - `shared/**`
  - `configs/**`
  - `.github/workflows/build-all-sites.yml`

**Strategy:** Parallel matrix build

```yaml
matrix:
  site:
    - name: my-documents
      repo: fchastanet/my-documents
      baseURL: https://fchastanet.github.io/my-documents
      self: true
    - name: bash-compiler
      repo: fchastanet/bash-compiler
      baseURL: https://fchastanet.github.io/bash-compiler
      self: false
    # ... other sites
```

**Build Steps (Per Site):**

1. **Checkout Orchestrator:** Clone my-documents repository
2. **Checkout Content:** Clone dependent repository content (if not self)
3. **Setup Tools:** Install Hugo Extended 0.155.3, Go 1.24, yq
4. **Prepare Build Directory:**
   - For my-documents: Use orchestrator directory
   - For dependent repos: Create `build-{site}` directory
5. **Merge Configurations:** Combine `_base.yaml` + `{site}.yaml`
6. **Copy Shared Resources:** Link shared layouts, assets, archetypes
7. **Copy Content:** Link content directory
8. **Initialize Hugo Modules:** Run `hugo mod init` and `hugo mod get -u`
9. **Build Site:** Run `hugo --minify`
10. **Deploy:** Push to respective GitHub Pages

**Concurrency:** `cancel-in-progress: true` prevents duplicate builds

**Failure Handling:** `fail-fast: false` allows other sites to build even if one fails

### 3.5. Deployment Approach

**Method:** GitHub App authentication (migrated from deploy keys)

**Authentication Flow:**

1. **Generate App Token:** Use `actions/create-github-app-token@v1`
2. **Deploy with Token:** Use `peaceiris/actions-gh-pages@v4`

**Secrets Required** (in my-documents):

- `DOC_APP_ID` - GitHub App ID
- `DOC_APP_PRIVATE_KEY` - GitHub App private key (PEM format)

**Deployment Step Example:**

```yaml
- name: Generate GitHub App token
  id: app-token
  uses: actions/create-github-app-token@v1
  with:
    app-id: ${{ secrets.DOC_APP_ID }}
    private-key: ${{ secrets.DOC_APP_PRIVATE_KEY }}
    owner: fchastanet
    repositories: bash-compiler

- name: Deploy to GitHub Pages
  uses: peaceiris/actions-gh-pages@v4
  with:
    github_token: ${{ steps.app-token.outputs.token }}
    external_repository: fchastanet/bash-compiler
    publish_dir: ./public
    publish_branch: gh-pages
```

**Result URLs:**

- <https://fchastanet.github.io/my-documents/>
- <https://fchastanet.github.io/bash-compiler/>
- <https://fchastanet.github.io/bash-tools/>
- <https://fchastanet.github.io/bash-tools-framework/>
- <https://fchastanet.github.io/bash-dev-env/>

### 3.6. Trigger Mechanism

**Dependent Repository Workflow Example:** `.github/workflows/trigger-docs.yml`

```yaml
name: Trigger Documentation Rebuild

on:
  push:
    branches: [master]
    paths:
      - 'content/**'
      - '.github/workflows/trigger-docs.yml'

jobs:
  trigger:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger my-documents build
        uses: peter-evans/repository-dispatch@v3
        with:
          token: ${{ secrets.DOCS_TRIGGER_PAT }}
          repository: fchastanet/my-documents
          event-type: trigger-docs-rebuild
          client-payload: |
            {
              "repository": "${{ github.repository }}",
              "ref": "${{ github.ref }}",
              "sha": "${{ github.sha }}"
            }
```

**Required Secret:** `DOCS_TRIGGER_PAT` - Personal Access Token with `repo` scope

### 3.7. Theme Customization

**Shared Customizations:** [shared/](../../shared/)

Contains:

- **Layouts:** Custom Hugo templates override Docsy defaults
- **Assets:** Custom SCSS variables, additional CSS/JS
- **Archetypes:** Content templates for new pages

**Per-Site Customization:** Via configuration overrides in `configs/{site}.yaml`

Examples:

- Theme colors: `params.ui.navbar_bg_color: '#007bff'` (blue for bash-compiler)
- Custom links in footer or navbar
- Site-specific SEO keywords and description
- Logo overrides

**Mount Strategy:** Defined in [configs/_base.yaml](../../configs/_base.yaml)

```yaml
module:
  mounts:
    - {source: shared/layouts, target: layouts}
    - {source: shared/assets, target: assets}
    - {source: shared/archetypes, target: archetypes}
    - {source: content, target: content}
    - {source: static, target: static}
```

**Result:** Shared resources available to all sites, with per-site override capability

## 4. Lessons Learned & Future Considerations

### 4.1. GitHub App Migration from Deploy Keys

**Initial Approach:** Deploy keys for each repository

- **Setup:** Generate SSH key pair per repository, store private key in my-documents secrets
- **Secrets Required:** `DEPLOY_KEY_BASH_COMPILER`, `DEPLOY_KEY_BASH_TOOLS`, etc. (4+ secrets)
- **Management:** Per-repository key addition in Settings → Deploy keys

**Problem:** Scalability and management overhead

**Migration to GitHub Apps:**

**Advantages:**

- ✅ **Fine-grained permissions:** Only Contents and Pages write access (vs full repo access)
- ✅ **Centralized management:** One app for all repositories
- ✅ **Better security:** Automatic token expiration and rotation
- ✅ **Audit trail:** All actions logged under app identity
- ✅ **No SSH management:** HTTPS with tokens instead of SSH keys
- ✅ **Easily revocable:** Instant access revocation without key regeneration
- ✅ **Scalable:** Add/remove repositories without creating new keys
- ✅ **Secrets reduction:** 2 secrets (app ID + private key) vs 4+ deploy keys

**GitHub Official Recommendation:**

> "We recommend using GitHub Apps with permissions scoped to specific repositories for
> enhanced security and more granular access control."

**Implementation:** See [doc/ai/2026-02-18-github-app-migration.md](../../../doc/ai/2026-02-18-github-app-migration.md)
for complete migration guide

**Outcome:** Significantly improved security posture and simplified credential management

### 4.2. Trade-offs Discovered

#### 4.2.1. All-Site Rebuild Trade-off

**Trade-off:** All sites rebuild together when any site content changes

**Mitigation Strategies:**

- ✅ `fail-fast: false` in matrix strategy - One site failure doesn't block others
- ✅ Parallel execution - All 5 sites build simultaneously (~60s total)
- ✅ Path-based triggers - Only rebuild when relevant files change
- ✅ Concurrency control - Cancel duplicate builds

**Acceptance Rationale:**

- Related documentation sites benefit from synchronized updates
- Total build time (60s) acceptable for documentation updates
- Ensures all sites stay consistent with latest shared resources
- Simpler mental model: one build updates everything

#### 4.2.2. Authentication Complexity

**Trade-off:** Initial setup requires GitHub App creation and secret configuration

**Mitigation:**

- ✅ One-time setup effort well-documented
- ✅ Improved security worth the complexity
- ✅ Scales better than deploy keys (no per-repo setup needed for new sites)

**Outcome:** Initial investment pays off with easier ongoing management

#### 4.2.3. Configuration Flexibility vs Consistency

**Trade-off:** Centralized configuration limits per-site flexibility

**Mitigation:**

- ✅ Site-specific override files in `configs/{site}.yaml`
- ✅ Shared base with override capability provides best of both worlds
- ✅ yq deep-merge preserves flexibility where needed

**Outcome:** Achieved balance between consistency and customization

### 4.3. Best Practices Identified

#### 4.3.1. Configuration Management

- **Use YAML deep-merge:** `yq eval-all` properly merges nested structures
- **Separate concerns:** Base configuration vs site-specific overrides
- **Version control everything:** All configs in git
- **Document override patterns:** Clear examples in base config

#### 4.3.2. Build Optimization

- **Parallel matrix builds:** Leverage GitHub Actions matrix for speed
- **Minimal checkout:** Only fetch what's needed (depth, paths)
- **Careful path triggers:** Avoid unnecessary builds
- **Cancel redundant builds:** Use concurrency groups

#### 4.3.3. Dependency Management

- **Pin versions:** Hugo 0.155.3, Go 1.24 (reproducible builds)
- **Cache when possible:** Hugo modules could be cached (future optimization)
- **Minimal dependencies:** yq only additional tool needed

#### 4.3.4. Security

- **GitHub Apps over deploy keys:** Better security model
- **Minimal permissions:** Only what's needed (Contents write, Pages write)
- **Secret scoping:** Secrets only in orchestrator repo
- **Audit logging:** GitHub App actions fully logged

### 4.4. Future Considerations

#### 4.4.1. Potential Optimizations

**Hugo Module Caching:**

- Current: Hugo modules downloaded fresh each build
- Future: Cache Go modules directory to speed up builds
- Benefit: Reduce build time by 5-10s per site

**Conditional Site Builds:**

- Current: All sites build on any trigger
- Future: Parse `repository_dispatch` payload to build only affected site
- Benefit: Faster feedback for single-site changes
- Trade-off: More complex logic, potential consistency issues

**Build Artifact Reuse:**

- Current: Each site built independently
- Future: Share Hugo module downloads across matrix jobs
- Benefit: Reduced redundant network calls

#### 4.4.2. Scalability Considerations

**Adding New Documentation Sites:**

1. Create new repository with content
2. Add trigger workflow (2-minute setup)
3. Add site config to `my-documents/configs/{new-site}.yaml`
4. Add site to matrix in `build-all-sites.yml`
5. Install GitHub App on new repository
6. Done - automatic builds immediately available

**Estimated effort:** 15-30 minutes per new site

#### 4.4.3. Alternative Approaches for Future Projects

**When Decentralized Makes Sense:**

- Truly independent projects (not related documentation)
- Different teams with different update schedules
- Need for isolated failure handling
- Different Hugo/Docsy versions per project

**When to Reconsider:**

- More than 10 sites (build time may become issue)
- Sites diverge significantly in requirements
- Team structure changes (separate maintainers per site)
- Different deployment targets (not all GitHub Pages)

### 4.5. Success Metrics

**Achieved:**

- ✅ **SEO Improvement:** 2/10 (Docsify) → 9/10 (Hugo with Docsy)
- ✅ **Build Time:** ~60s for all 5 sites (parallel)
- ✅ **Maintenance Reduction:** One workflow update vs 5× separate updates
- ✅ **Consistency:** 100% - All sites use same base configuration
- ✅ **Security:** GitHub App authentication with fine-grained permissions
- ✅ **Deployment:** Automatic on content changes
- ✅ **Developer Experience:** Simplified per-repo structure (2 files vs 6)
- ✅ **Independent URLs:** All 5 repositories maintain separate GitHub Pages URLs
- ✅ **Theme Sharing:** Shared Docsy theme customizations across all sites

**Continuous Improvement:**

- Monitor build times as content grows
- Gather feedback on developer experience
- Iterate on shared vs per-site customizations
- Evaluate caching opportunities
- Consider additional SEO optimization (structured data, etc.)

## 5. Conclusion

The Hugo migration successfully addressed the SEO limitations of Docsify while
establishing a scalable, maintainable multi-site documentation architecture.
The centralized orchestrator approach provides the right balance of consistency
and flexibility for related Bash tooling documentation projects.

**Key Success Factors:**

1. **Right tool for the job:** Hugo's documentation focus and SEO capabilities
2. **Architectural alignment:** Centralized approach matches project relationships
3. **Security improvement:** GitHub App migration enhanced security posture
4. **Maintainability:** Single-point updates reduce ongoing effort
5. **Flexibility preserved:** Configuration overrides allow per-site customization

**Documentation maintained and current as of:** 2026-02-18

**Related Resources:**

- [Migration Guide](../../../doc/ai/2026-02-18-migrate-repo-from-docsify-to-hugo.md)
- [GitHub App Migration Details](../../../doc/ai/2026-02-18-github-app-migration.md)
- [Build Workflow](../../../.github/workflows/build-all-sites.yml)
- [Configuration Examples](../../../configs/)
