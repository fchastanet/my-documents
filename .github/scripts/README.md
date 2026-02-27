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
