# AI Instructions - my-documents Repository

## Repository Type

Reusable GitHub Action provider for Hugo/Docsy documentation sites.
Provides shared resources via Hugo modules to dependent repos (bash-compiler,
bash-tools, bash-tools-framework, bash-dev-env).

## Critical Non-Standard Conventions

### Git
- **Default branch:** `master` (NOT main)
- **Commit messages:** Markdown format (see `.github/commit-message.instructions.md`)
- **Chat responses:** Only provide relevant changes, not entire file contents

### File Naming & Formatting
- Markdown files: kebab-case (`HowTo-Write-Bash-Scripts.md`)
- Line length: 120 characters (enforced by MegaLinter, mdformat)
- Line endings: LF only

### Configuration
- **NEVER edit `hugo.yaml`** - it's generated at build time
- Edit `configs/_base.yaml` (affects all sites) or `configs/site-config.yaml` (this site only)
- Config merging: yq deep-merge, arrays are replaced not merged

### Frontmatter Rules
```yaml
title: Page Title              # Required
description: Brief description # Optional, for SEO
weight: 10                      # Optional, controls order (lower = higher)
categories: [documentation]     # Optional
tags: [example]                 # Optional
creationDate: "2026-02-18"     # Required for new pages
lastUpdated: "2026-02-22"      # Update on every edit
version: "1.0"                  # Semantic versioning
```
**AI must update `lastUpdated` on edits, set `creationDate` on new pages.**

### Spell Checking
- Custom dictionaries in `.cspell/`
- Add technical terms to `.cspell/bash.txt`
- Dictionaries must be sorted alphabetically (enforced by pre-commit)

## Repository Structure

```text
configs/
  _base.yaml          # Base config (imported by all sites via Hugo modules, affects ALL sites)
  site-config.yaml    # This site's overrides
shared/
  layouts/            # Shared templates (available to all sites via Hugo modules)
  assets/            # Shared SCSS/CSS/JS (available to all sites)
  archetypes/        # Content templates
content/docs/        # my-documents content (subdirs: bash-scripts, howtos, lists, brainstorming, other-projects)
hugo.yaml            # GENERATED - never edit directly
```

## Reusable Action Architecture

**Impact of Changes:**
- `shared/layouts/`, `shared/assets/`, `configs/_base.yaml` → affects ALL dependent sites
- `configs/site-config.yaml` → affects only this site

**Hugo Modules Sharing:**
Dependent repos import shared resources via Hugo modules:
```yaml
module:
  imports:
    - path: github.com/fchastanet/my-documents
      mounts:
        - source: configs/_base.yaml
          target: config/_default/config.yaml
        - source: shared/layouts
          target: layouts
        - source: shared/assets
          target: assets
        - source: shared/archetypes
          target: archetypes
```

**Build Flow:**
Push to dependent repo → calls `.github/workflows/build-site-action.yml` → builds with Hugo → deploys to gh-pages branch

**Action Parameters:**
- `hugo-version`: 0.155.3 (default)
- `node-version`: 24 (default)
- `working-directory`: . (default)

## Local Development

**Testing:**
```bash
make start                         # Test my-documents site at http://localhost:1313/my-documents/
SITE=bash-compiler make start-site # Test dependent site
```

**Adding New Site Requirements:**
1. In dependent repo: `content/docs/`, `content/_index.md`, `configs/site-config.yaml`,
   `go.mod`, `.github/workflows/build-site.yml`
2. GitHub Pages: Settings → Pages → Source: "GitHub Actions"
3. No changes needed in my-documents (resources shared via Hugo modules)

## Workflows

**main.yml:** Pre-commit hooks + MegaLinter, creates auto-fix PRs (skip with "skip fix" in commit) + Builds Hugo site and deploys to GitHub Pages if master branch
**build-site.yml:** Builds Hugo site, deploys to GitHub Pages (gh-pages branch)

## Common Commands

```bash
hugo new docs/section/page-name.md     # Create new page
hugo server -D                         # Local preview
pre-commit run -a                      # Run all linters
hugo mod clean && hugo mod get -u      # Fix module issues
npx cspell --quiet .                   # Check spelling
npx cspell --debug --quiet .           # Check spelling with debug
```

**Add word to spell dictionary:**
```bash
echo "newWord" >> .cspell/bash.txt
pre-commit run file-contents-sorter   # Sort dictionary
```

## Editor Agent Guidelines

1. **Shared component changes** (`shared/`, `configs/_base.yaml`) → affects ALL 5 sites, test thoroughly
2. **Config editing:** Never edit `hugo.yaml` (generated), edit `configs/_base.yaml` or `configs/site-config.yaml`
3. **Frontmatter updates:** Always update `lastUpdated` field when editing, add `creationDate` when creating new pages
4. **Spell checking:** Add technical terms to `.cspell/bash.txt`, keep sorted
5. **Testing:** Use `make start` to test changes locally
6. **Default branch:** Use `master` (not `main`)
