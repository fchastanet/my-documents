# Copilot Prompt: Migrate Repository from Docsify to Hugo/Docsy

Target repos: `[repo-name]`, `bash-tools`, `bash-tools-framework`, `bash-dev-env`

Repos migrate from Docsify to Hugo/Docsy, calling reusable action from `fchastanet/my-documents`.

## Migration Steps

### Step 1: Analyze Current Docsify Structure

```bash
# Identify Docsify files:
ls -la | grep -E "index.html|_sidebar.md|_navbar.md|.nojekyll"
```

Move docs/ content to content/docs/

### Step 2: Create Hugo Content Structure

```bash
mkdir -p content/docs
```

Create `content/_index.md`:
```markdown
---
title: [Site Title]
linkTitle: [Site Title]
description: [Brief description]
type: docs
weight: [10 then 20, 30...]
creationDate: [Current date format YYYY-MM-DD]
lastUpdated: [Current date format YYYY-MM-DD]
---
```

Create `content/docs/_index.md`:
```markdown
---
title: Documentation
linkTitle: Documentation
description: Complete documentation for [Project Name]
type: docs
weight: 1
creationDate: [Current date format YYYY-MM-DD]
lastUpdated: [Current date format YYYY-MM-DD]
---

{{< articles-list >}}
```

`_index.md` files serve as landing pages for sections, with frontmatter defining metadata and content structure. They will not contain actual documentation content but will provide an overview and navigation for the section.

### Step 3: Migrate Content

Move markdown files from docs/ to content/docs/, organize into subdirectories.

Add frontmatter to all pages:
```yaml
---
title: Page Title
description: Brief description
weight: 10
categories: [documentation]
tags: [example]
creationDate: [see creationDate rule below]
lastUpdated: [see lastUpdated rule below]
version: "1.0"
---
```

creationDate rules: get file creation date using
`git log --follow --format=%aI --pretty="format:%ad" --date=format:'%Y-%m-%d' filename | tail -1`
eg: `git log --follow --format=%aI --pretty="format:%ad" --date=format:'%Y-%m-%d' content/docs/howtos/howto-write-jenkinsfile/01-how-jenkins-works.md | tail -1`

lastUpdated rules: get last modification date using
`git log --follow --format=%aI --pretty="format:%ad" --date=format:'%Y-%m-%d' filename | head -1`
eg: `git log --follow --format=%aI --pretty="format:%ad" --date=format:'%Y-%m-%d' content/docs/howtos/howto-write-jenkinsfile/01-how-jenkins-works.md | head -1`

Update internal links from `[text](page.md)` to `/docs/section/page/` (no .md extension).

Move images in `assets/` folder in the same directory where the file is used. If the file is used by multiple pages, keep it in `static/images/`. In any case, update references to `/images/filename.ext`.

### Step 4: Create Hugo Configuration Files

Create `go.mod`:
```go
module github.com/fchastanet/[repo-name]

go 1.24

require (
  github.com/google/docsy v0.14.3 // indirect
  github.com/google/docsy/dependencies v0.7.2 // indirect
)
```

Create `configs/site-config.yaml`:
```yaml
# Site-specific configuration for [repo-name]
title: [Repo Name] Documentation
baseURL: https://fchastanet.github.io/[repo-name]/

params:
  description: '[Repo Name] - [Brief description]'
  keywords: '[comma-separated keywords]'

  # Repository configuration
  github_repo: https://github.com/fchastanet/[repo-name]
  github_project_repo: https://github.com/fchastanet/[repo-name]

  # UI Configuration - Blue theme
  ui:
    navbar_bg_color: '#007bff'

  # Links
  links:
    user:
      - name: GitHub
        url: https://github.com/fchastanet/[repo-name]
        icon: fab fa-github
        desc: [repo-name] repository
      - name: Issues
        url: https://github.com/fchastanet/[repo-name]/issues
        icon: fas fa-bug
        desc: Report issues

  # SEO
  meta:
    description: '[Repo Name] documentation - [Brief description]'
    keywords: '[comma-separated keywords]'

menu:
  site:
    - name: GitHub
      url: https://github.com/fchastanet/[repo-name]
      weight: 10
      post: <sup><i class="ps-1 fa-solid fa-up-right-from-square fa-xs" aria-hidden="true"></i></sup>
    - name: Release Notes
      url: https://github.com/fchastanet/[repo-name]/releases
      weight: 20
      post: <sup><i class="ps-1 fa-solid fa-up-right-from-square fa-xs" aria-hidden="true"></i></sup>

```

Create `assets/scss/_variables_project_override.scss`:
```scss
$primary: #007bff;
$secondary: #6c757d;
```

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
      - 'go.sum'
  workflow_dispatch:

concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true

jobs:
  build-deploy:
    uses: fchastanet/my-documents/.github/workflows/build-site-action.yml@master
    with:
      site-name: '[repo-name]'
      baseURL: 'https://fchastanet.github.io/[repo-name]'
      checkout-repo: 'fchastanet/[repo-name]'
    permissions:
      contents: read
      pages: write
      id-token: write
```

Download modules:
```bash
hugo mod get -u
```

### Step 5: Remove Docsify Files

```bash
rm -f index.html .nojekyll
rm -f docs/_sidebar.md docs/_navbar.md
```

Update `.gitignore`:
```text
build/
public/
sites/
resources/
.hugo_build.lock
hugo.yaml
```

### Step 6: Configure GitHub Pages

Repository Settings → Pages:
- Source: Select "GitHub Actions"

Repository Settings → Actions → General:
- Workflow permissions: Select **Read and write permissions**
- Check: **Allow GitHub Actions to create and approve pull requests**

### Step 7: Test Locally

```bash
hugo mod get -u
hugo --minify
hugo server -D  # Visit http://localhost:1313/[repo-name]/
```

Verify:
- All pages render correctly
- Navigation menu works
- Internal links resolve (no 404s)
- Images display properly
- Code blocks have syntax highlighting

### Step 8: Quality Checks

```bash
# Check for broken links (should find none)
grep -r "](.*\.md)" content/

# Check for missing frontmatter
find content -name "*.md" -exec sh -c 'head -5 "$1" | grep -q "^---$" || echo "Missing: $1"' _ {} \;

# Check for Docsify syntax remnants
grep -r "docsify" content/

# Verify image paths
find content -name "*.md" -exec grep -H "!\[.*\](.*)" {} \;
```

### Step 9: Commit and Push

```bash
git add go.mod go.sum configs/site-config.yaml .github/workflows/build-site.yml
git add content/ static/ .gitignore
git add -u  # Stage deletions

git commit -m "feat: migrate documentation from Docsify to Hugo/Docsy"
git push origin master
```

### Step 10: Verify Deployment

Check Actions tab in repository - build workflow should complete successfully.

Verify GitHub Pages:
- Settings → Pages
- Check deployment status
- URL: `https://fchastanet.github.io/[repo-name]/`

Test deployed site:
- Navigate through all sections
- Verify links and images work
- Test search functionality

## File Structure After Migration

```
[repo-name]/
├── .github/workflows/
│   └── build-site.yml
├── configs/
│   └── site-config.yaml
├── content/
│   ├── _index.md
│   └── docs/
│       ├── _index.md
│       ├── section1/
│       └── section2/
├── static/
│   └── images/
├── assets/
│   └── scss/
│       └── _variables_project_override.scss
├── go.mod
├── go.sum
├── .gitignore
└── [other repo files]
```

Required files:
- `go.mod` - Hugo module configuration
- `go.sum` - Module checksums (auto-generated)
- `configs/site-config.yaml` - Site-specific configuration
- `.github/workflows/build-site.yml` - Deployment workflow
- `content/` - Documentation in Hugo structure
- `static/` - Static assets (images, downloads)
- `assets/scss/_variables_project_override.scss` - Custom SCSS variables for project-specific styling
