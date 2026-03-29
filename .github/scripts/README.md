# Build Scripts Directory

This directory contains reusable bash scripts extracted from the Makefile to maintain clean, maintainable code.

## Files Overview

### `colors.sh`

Shared color definitions for consistent output across all scripts.

**Usage in scripts:**

```bash
source "$(dirname "$0")/colors.sh"
echo -e "${GREEN}Success${NC}"
```

**Available colors:**
- `BLUE` - Information
- `GREEN` - Success
- `YELLOW` - Warnings
- `RED` - Errors
- `NC` - No Color (reset)

### `install-hugo.sh`

Install Hugo extended build.

**Usage:**

```bash
.github/scripts/install-hugo.sh [VERSION]
```

**Example:**

```bash
.github/scripts/install-hugo.sh 0.155.3
```

### `install-yq.sh`

Install yq YAML processor.

**Usage:**

```bash
.github/scripts/install-yq.sh
```

### `link-repos.sh`

Create symlinks to dependent repositories for local testing.

**Usage:**

```bash
.github/scripts/link-repos.sh SITES_DIR REPO1 REPO2 ...
```

**Example:**

```bash
.github/scripts/link-repos.sh sites bash-compiler bash-tools bash-tools-framework bash-dev-env
```

### `unlink-repos.sh`

Remove symlinks to dependent repositories.

**Usage:**

```bash
.github/scripts/unlink-repos.sh SITES_DIR REPO1 REPO2 ...
```

**Example:**

```bash
.github/scripts/unlink-repos.sh sites bash-compiler bash-tools bash-tools-framework bash-dev-env
```

### `update-lastmod.sh`

Update `date`, `lastmod`, and `version` frontmatter fields in markdown files. Integrates with pre-commit hooks to
automatically manage Hugo frontmatter metadata.

**Two modes of operation:**

1. **Migration mode** (no arguments): Updates **all** `.md` files in `content/` directory
   - Migrates `creationDate` → `date`
   - Migrates `lastUpdated` → `lastmod`
   - Removes old field names
   - Adds `version: "1.0"` if version field doesn't exist
   - Uses git history for dates if old fields don't exist
   - Places `date`, `lastmod`, and `version` at the **end** of frontmatter

2. **Commit mode** (with file arguments): Updates specific files being committed
   - Adds `date` if missing (current timestamp)
   - Updates `lastmod` (current timestamp) **only if not already updated today**
   - Adds `version: "1.0"` if missing, or **increments** existing version (e.g., 1.2 → 1.3)
     **only if not already updated today**
   - Places `date`, `lastmod`, and `version` at the **end** of frontmatter
   - **Smart update detection**: Skips `lastmod` and `version` updates if `lastmod` already has today's date (prevents
   repeated updates on multiple commit attempts)

**Usage:**

```bash
# Migration mode: migrate all files
.github/scripts/update-lastmod.sh

# Commit mode: update specific files (called by pre-commit)
.github/scripts/update-lastmod.sh content/docs/page1.md content/docs/page2.md
```

**Date format:**
- Format: `2023-10-19T08:00:00+02:00` (ISO 8601 with timezone)
- Timezone: Europe/Paris
- Default time: 08:00:00 (when only date is available)

**Version increment:**
- Increments the last number in the version: `1.2` → `1.3`, `2.15` → `2.16`
- Supports formats: `X.Y` or `X.Y.Z`
- Example: `1.9` → `1.10`, not `2.0`

**Git integration:**
- Uses `git log --follow` to find file creation date
- Uses `git log -1` to find last modification date
- Falls back to current date if file not in git yet

**Pre-commit hook:**

The script is automatically called by pre-commit hooks for any `.md` files in `content/`:

```yaml
- id: update-lastmod
  name: Update date and lastmod frontmatter
  language: system
  files: ^content/.*\.md$
  entry: .github/scripts/update-lastmod.sh
  stages: [pre-commit]
```

**Smart update behavior in commit mode:**

The script prevents unnecessary updates when you commit multiple times on the same day:

- **First commit of the day**: Updates `lastmod` and increments `version`
- **Subsequent commits on same day**: Skips updates (no changes)
- **Commit on different day**: Updates `lastmod` and increments `version`

This prevents the infinite loop problem where:
1. You commit → fields updated
2. You stage changes and commit again → fields would update again (✗)
3. This would repeat indefinitely

Now with the smart detection:
1. You commit → fields updated with today's date
2. You stage changes and commit again → skipped (already updated today) ✓
3. You can use `git commit --amend` safely ✓

**Migration process:**

To migrate existing content from old frontmatter fields:

```bash
# 1. Backup your content (optional)
git stash

# 2. Run migration on all files
.github/scripts/update-lastmod.sh

# 3. Review changes
git diff

# 4. Commit migration
git add content/
git commit -m "docs: Migrate frontmatter to Hugo standard date fields"
```

**Frontmatter transformation:**

Before (old format):

```yaml
---
title: My Page
description: Page description
categories: [docs]
weight: 10
creationDate: '2026-02-18'
lastUpdated: '2026-02-22'
version: '1.2'
---
```

After migration:

```yaml
---
title: My Page
description: Page description
categories: [docs]
weight: 10
date: "2026-02-18T08:00:00+01:00"
lastmod: "2026-02-22T08:00:00+01:00"
version: "1.2"
---
```

After commit (version incremented):

```yaml
---
title: My Page
description: Page description
categories: [docs]
weight: 10
date: "2026-02-18T08:00:00+01:00"
lastmod: "2026-03-29T15:53:17+02:00"
version: "1.3"
---
```

Commit again same day (no changes):

```yaml
---
title: My Page
description: Page description
categories: [docs]
weight: 10
date: "2026-02-18T08:00:00+01:00"
lastmod: "2026-03-29T15:53:17+02:00"
version: "1.3"
---
```

**Hugo date field behavior:**

See Hugo documentation:
- [Page.Date()](https://gohugo.io/methods/page/date/) - Primary date
- [Page.Lastmod()](https://gohugo.io/methods/page/lastmod/) - Last modification

### `build-site.sh`

Build a specific documentation site.

**Usage:**

```bash
.github/scripts/build-site.sh SITE [BUILD_DIR] [SITES_DIR]
```

**Example:**

```bash
.github/scripts/build-site.sh bash-compiler build sites
```

### `build-all.sh`

Build all documentation sites in parallel.

**Usage:**

```bash
.github/scripts/build-all.sh [BUILD_DIR] [SITES_DIR] REPO1 REPO2 ...
```

**Example:**

```bash
.github/scripts/build-all.sh build sites bash-compiler bash-tools bash-tools-framework bash-dev-env
```

**What it does:**
1. Builds my-documents first
2. Then builds all dependent repositories in sequence
3. Each site gets its own config merged from base + site-specific

### `test-all.sh`

Test all built sites with curl to verify they work.

**Usage:**

```bash
.github/scripts/test-all.sh [BUILD_DIR] [SITES_DIR] REPO1 REPO2 ...
```

**Example:**

```bash
.github/scripts/test-all.sh build sites bash-compiler bash-tools bash-tools-framework bash-dev-env
```

## Parameters

All scripts use relative paths by default:

| Parameter   | Default   | Purpose                                |
| ----------- | --------- | -------------------------------------- |
| `BUILD_DIR` | `build`   | Build output directory                 |
| `SITES_DIR` | `sites`   | Symlink directory for dependencies     |
| `SITE`      | -         | Single site to build (required)        |
| `VERSION`   | `0.155.3` | Hugo version to install                |
| `REPOS`     | -         | List of repositories (space-separated) |

## Using with Makefile

The Makefile delegates to these scripts while keeping complex logic out of the Makefile:

```makefile
install-hugo:
    @$(SCRIPT_DIR)/install-hugo.sh $(HUGO_VERSION)

link-repos:
    @$(SCRIPT_DIR)/link-repos.sh $(SITES_DIR) $(REPOS)

build-site:
    @$(SCRIPT_DIR)/build-site.sh $(SITE) $(BUILD_DIR) $(SITES_DIR)
```

## Direct Script Usage

Scripts can be executed directly without the Makefile:

```bash
# Install tools
.github/scripts/install-hugo.sh
.github/scripts/install-yq.sh

# Setup repos
.github/scripts/link-repos.sh sites bash-compiler bash-tools

# Build
.github/scripts/build-site.sh bash-compiler build sites

# Or build all
.github/scripts/build-all.sh build sites bash-compiler bash-tools

# Test
.github/scripts/test-all.sh build sites bash-compiler bash-tools
```

## Error Handling

All scripts use strict error handling:

```bash
set -euo pipefail
```

This means:
- `-e` - Exit on any error
- `-u` - Exit if undefined variable is used
- `-o pipefail` - Exit if any command in pipeline fails

## Adding New Scripts

When adding new scripts:

1. **Source colors.sh** at the top:

   ```bash
   source "$(dirname "$0")/colors.sh"
   ```

2. **Use strict mode**:

   ```bash
   set -euo pipefail
   ```

3. **Accept parameters** for flexibility:

   ```bash
   PARAM="${1:?Error: PARAM required}"
   ```

4. **Add usage comment** at the top:

   ```bash
   # Usage: ./script.sh PARAM1 PARAM2
   ```

5. **Use color output**:

   ```bash
   echo -e "${BLUE}Starting...${NC}"
   echo -e "${GREEN}Success!${NC}"
   echo -e "${YELLOW}Warning${NC}"
   echo -e "${RED}Error${NC}"
   ```

## Testing Scripts

To test a script locally:

```bash
# Make executable (automated in CI)
chmod +x .github/scripts/script-name.sh

# Run directly
.github/scripts/script-name.sh arg1 arg2

# Or via Makefile
make target-name
```

## CI/CD Integration

These scripts are used in GitHub Actions workflows:

- `.github/workflows/build-all-sites.yml` - Orchestrator build
- `.github/workflows/main.yml` - Linting and validation and deployment on master branch

They can be called from any shell environment with:

```yaml
- name: Run build script
  run: .github/scripts/build-site.sh bash-compiler
```

## Troubleshooting

### Script not found

```text
./script.sh: No such file or directory
```

**Solution:** Ensure scripts are executable:

```bash
chmod +x .github/scripts/*.sh
```

### Cannot locate colors.sh

```text
source: line 1: /path/to/colors.sh: No such file or directory
```

**Solution:** Scripts must be run from correct directory or absolute path used.

### Permission denied

```text
-bash: ./script.sh: Permission denied
```

**Solution:**

```bash
chmod +x .github/scripts/*.sh
```

## Maintenance Notes

- Keep scripts focused on single responsibility
- Use descriptive variable names
- Add comments for complex logic
- Test scripts before committing
- Update this README when adding new scripts
