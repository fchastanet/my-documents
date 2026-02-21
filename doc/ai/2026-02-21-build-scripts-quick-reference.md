# Quick Reference: New Build Scripts

## Script Overview

| Script | Purpose | Usage |
|--------|---------|-------|
| `merge-configs.sh` | Merge base + site config | `merge-configs.sh BASE SITE OUTPUT [URL]` |
| `copy-shared-resources.sh` | Copy layouts/assets/archetypes | `copy-shared-resources.sh SRC TARGET` |
| `prepare-build.sh` | Complete build prep (orchestration) | `prepare-build.sh SITE IS_SELF ORCH SRC OUT [URL]` |
| `initialize-modules.sh` | Init Go modules | `initialize-modules.sh BUILD_DIR [SITE]` |
| `build-hugo.sh` | Build with Hugo | `build-hugo.sh BUILD_DIR [SITE] [URL]` |
| `deploy-site.sh` | Deploy to GitHub Pages | `deploy-site.sh SITE PUBLIC REPO [TOKEN]` |

## Usage Examples

### CI/CD Workflow (in build-all-sites.yml)
```bash
# Prepare build directory
bash orchestrator/.github/scripts/prepare-build.sh \
  "${{ matrix.site.name }}" \
  "${{ matrix.site.self }}" \
  "orchestrator" \
  "sites/${{ matrix.site.name }}" \
  "$BUILD_DIR" \
  "${{ matrix.site.baseURL }}"

# Initialize Go modules
bash ../orchestrator/.github/scripts/initialize-modules.sh "." "${{ matrix.site.name }}"

# Build with Hugo
bash ../orchestrator/.github/scripts/build-hugo.sh "." "${{ matrix.site.name }}" "${{ matrix.site.baseURL }}"
```

### Local Development
```bash
# Build a specific site
./build-site.sh bash-compiler build sites

# Build all dependent sites
./build-all.sh build sites bash-compiler bash-tools bash-tools-framework bash-dev-env

# Or use Make commands (recommended)
make build-site SITE=bash-compiler
make build-all
```

## Script Responsibilities

### `prepare-build.sh`
**Orchestrator Script** - Coordinates multiple operations

**For Self (my-documents):**
1. ✓ Merge base + my-documents config to `hugo.yaml`

**For Dependent Sites:**
1. ✓ Copy shared layouts, assets, archetypes
2. ✓ Copy site content and static files
3. ✓ Copy go.mod/go.sum if available
4. ✓ Merge base + site-specific config
5. ✓ Fall back to orchestrator go.mod if needed

**Output:** Ready-to-build directory with `hugo.yaml` and all resources

---

### `merge-configs.sh`
**Utility** - Config handling

**Operations:**
1. Validates that both config files exist
2. Deep-merges using `yq eval-all`
3. Optionally sets baseURL
4. Reports status

**Output:** Merged `hugo.yaml` file

---

### `copy-shared-resources.sh`
**Utility** - Resource distribution

**Operations:**
1. Copies `layouts/` directory
2. Copies `assets/` directory
3. Copies `archetypes/` directory
4. Creates target directories as needed

**Output:** Populated target build directory

---

### `initialize-modules.sh`
**Utility** - Go dependency management

**Operations:**
1. `go get -u ./...` - Download/update Hugo modules
2. `go mod tidy` - Clean dependencies

**Output:** Ready-to-build Go environment

---

### `build-hugo.sh`
**Utility** - Hugo build execution

**Operations:**
1. Sets environment variables (HUGO_CACHEDIR, HUGO_ENVIRONMENT)
2. Runs `hugo --minify` with diagnostic flags
3. Reports build size

**Output:** Built site in `public/` directory

---

### `deploy-site.sh`
**Utility** - Deployment preparation (informational)

**Operations:**
1. Configures git for GitHub Actions
2. Validates prerequisites
3. Reports deployment info

**Note:** Actual deployment handled by `peaceiris/actions-gh-pages@v4`

---

## Troubleshooting

### Script Not Found
```bash
# Ensure scripts are executable
chmod +x .github/scripts/*.sh

# Run with explicit bash if needed
bash .github/scripts/prepare-build.sh ...
```

### yq Not Installed
```bash
# Install yq (required for config merging)
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq
yq --version
```

### Hugo Not Found
```bash
# Install Hugo Extended (required for SCSS processing)
# See .github/scripts/install-hugo.sh or Makefile
```

### Go Modules Issues
```bash
# If go.mod is missing, copy from orchestrator root
cp go.mod BUILD_DIR/
cp go.sum BUILD_DIR/
```

---

## Integration Points

### GitHub Actions Workflow
- Calls scripts with working directory set appropriately
- Scripts use relative paths from repository root
- Environment variables available from GitHub Actions context

### Local Development
- Scripts assume standard directory structure
- Can be called from repository root or `.github/scripts/` directory
- Uses Make targets for simplified invocation

### Makefiles Targets
```bash
make build-site SITE=bash-compiler       # Uses build-site.sh
make build-all                           # Uses build-all.sh
```

---

## Common Patterns

### Building a Single Site Locally
```bash
cd /home/wsl/fchastanet/my-documents
./github/scripts/prepare-build.sh bash-compiler false . sites/bash-compiler build/bash-compiler
./github/scripts/initialize-modules.sh build/bash-compiler bash-compiler
./github/scripts/build-hugo.sh build/bash-compiler bash-compiler
```

### Building All Sites Locally
```bash
cd /home/wsl/fchastanet/my-documents
make build-all
```

### Testing Config Merging
```bash
cd /home/wsl/fchastanet/my-documents
./github/scripts/merge-configs.sh configs/_base.yaml configs/bash-compiler.yaml /tmp/test-hugo.yaml
yq eval . /tmp/test-hugo.yaml  # Inspect merged config
```

---

## Performance Notes

### Build Times
- **prepare-build.sh:** ~1-2s (file copying + config merge)
- **initialize-modules.sh:** ~10-20s (Go module download, cached)
- **build-hugo.sh:** ~15-30s per site (depends on content size)
- **Total for all 5 sites:** ~60s in CI (parallel via matrix)

### Optimization Tips
1. Use Go module caching (`{{runner.temp}}/hugo_cache` in CI)
2. Pre-cache Hugo modules between builds
3. Run parallel builds for multiple sites (matrix strategy)
4. Use minified output for production builds

---

## Reference Documentation

For more details, see:
- [Workflow Refactoring Document](./2026-02-21-refactor-workflow-scripts.md)
- [Copilot Instructions](../../.github/copilot-instructions.md)
- [Makefile](../../Makefile)
