# Build Scripts Directory

This directory contains reusable bash scripts extracted from the Makefile to maintain clean, maintainable code.

## Files Overview

### `colors.sh`

Shared color definitions for consistent output across all scripts.

**Usage in scripts:**

```bash
source "$(dirname "$0")/colors.sh"
echo -e "${COLOR_SUCCESS}Success${COLOR_RESET}"
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
.github/scripts/install-hugo.sh v0.166.0
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

| Parameter   | Default    | Purpose                                |
| ----------- | ---------- | -------------------------------------- |
| `BUILD_DIR` | `build`    | Build output directory                 |
| `SITES_DIR` | `sites`    | Symlink directory for dependencies     |
| `SITE`      | -          | Single site to build (required)        |
| `VERSION`   | `v0.166.0` | Hugo version to install                |
| `REPOS`     | -          | List of repositories (space-separated) |

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
   echo -e "${COLOR_INFO}Starting...${COLOR_RESET}"
   echo -e "${COLOR_SUCCESS}Success!${COLOR_RESET}"
   echo -e "${COLOR_WARNING}Warning${COLOR_RESET}"
   echo -e "${COLOR_ERROR}Error${COLOR_RESET}"
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

### Dart Sass not found / unexpected EOF

```text
TOCSS-DART: failed to transform "/scss/main.scss". You need to install Dart Sass
TOCSS-DART: failed to transform "/scss/main.scss": got unexpected EOF when executing "sass"
```

**Solution:** Docsy v0.17+ transpiles with Dart Sass. Run `npm ci` — the
`sass-embedded` devDependency provides it, and `build-hugo.sh` adds
`node_modules/.bin` to `PATH`.

The second error means the wrong binary was used: the pure-JS `sass` package
cannot be driven by Hugo. Its `dartsass` transpiler communicates over the
Embedded Sass protocol, which only `sass-embedded` (or a standalone dart-sass
binary) implements.

Both packages declare a bin named `sass`, so whichever npm links last wins
`node_modules/.bin/sass`. Do not add `sass` to `package.json` — `sass-embedded`
already pulls it in as a fallback for unsupported platforms. To keep the choice
deterministic, `bin/dart-sass` wraps sass-embedded's entry point and is placed
first on `PATH` by `build-hugo.sh` and the Makefile; Hugo looks for `dart-sass`
before `sass`, so the collision no longer matters.

### Can't find stylesheet to import

```text
assets/scss/td/_main.scss:3:8: Can't find stylesheet to import.
```

**Solution:** Docsy v0.17+ mounts Bootstrap and Font Awesome from
`node_modules`, resolved against the Hugo project root — which is the build
directory, not the repo root. `prepare-build.sh` hard-links `node_modules` in;
make sure `npm ci` ran in the orchestrator checkout first.

### Node.js permission error on a symlink

```text
POSTCSS: symlink "<project>/.venv/bin/python" resolves to "..." outside the
paths Node.js is allowed to access
```

**Solution:** Since Hugo v0.166.0, Node tools refuse to run if a symlink inside
the project resolves outside the allowed roots. This affects production builds
run directly from the repo root (`make build` is unaffected, as it builds in
`build/<site>/`). Either move the offending directory out of the repository or
add its target to `security.node.permissions.allowRead`.

## Maintenance Notes

- Keep scripts focused on single responsibility
- Use descriptive variable names
- Add comments for complex logic
- Test scripts before committing
- Update this README when adding new scripts
