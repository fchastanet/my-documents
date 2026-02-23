# Copilot Prompt: Migrate Repository from Docsify to Hugo/Docsy

Target repos: `bash-compiler`, `bash-tools`, `bash-tools-framework`, `bash-dev-env`

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
description: [Brief description]
---
```

Create `content/docs/_index.md`:
```markdown
---
title: Documentation
description: Complete documentation for [Project Name]
weight: 1
---
```

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
creationDate: "2026-02-18"
lastUpdated: "2026-02-22"
version: "1.0"
---
```

Update internal links from `[text](page.md)` to `/docs/section/page/` (no .md extension).

Move images to `static/images/`, update references in markdown.

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
baseURL: https://fchastanet.github.io/[repo-name]
title: [Repo Name] Documentation

params:
  description: "Documentation for [Repo Name]"
  ui:
    navbar_bg_color: "#007bff"
  github_repo: https://github.com/fchastanet/[repo-name]
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

## Troubleshooting

### Module Errors

```bash
hugo mod clean
rm go.sum
hugo mod get -u
```

Verify go.mod syntax and module path matches repository.

### Base Configuration Not Applied

Verify hugo.yaml imports base config:
```yaml
module:
  imports:
    - path: github.com/fchastanet/my-documents
      mounts:
        - source: configs/_base.yaml
          target: config/_default/config.yaml
```

Check modules: `hugo mod graph`

### Workflow Permissions Errors

Settings → Actions → General:
- Workflow permissions: **Read and write permissions**
- Allow GitHub Actions to create and approve pull requests: ✅

Settings → Pages:
- Source: **GitHub Actions** (not "Deploy from a branch")

### Hugo Server Fails

```bash
# Verify Hugo Extended installed
hugo version  # Should show "extended"

# Download modules
hugo mod get -u

# Check frontmatter in markdown files (must be valid YAML)
```

### Broken Links

Use Hugo path format `/docs/section/page/` (no .md extension).

Verify file structure matches link references.

### Images Not Displaying

Move images to `static/images/`, reference as `/images/file.png`.

Verify images are committed to repository.

### Custom Styles Not Applied

Create `assets/scss/_variables_project_override.scss`:
```scss
$primary: #007bff;
$secondary: #6c757d;
```

Or use hugo.yaml params:
```yaml
params:
  ui:
    navbar_bg_color: "#007bff"
```

Clear cache: `rm -rf resources/_gen/`

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
