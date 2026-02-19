# Copilot Instructions for my-documents Repository

## Repository Overview

This is a **centralized multi-site orchestrator** that builds and deploys multiple documentation sites using **Hugo**
static site generator and the **Docsy** theme.

**Primary Purpose:** Build and deploy documentation sites for related Bash tooling projects

**Key Characteristics:**

- Orchestrates builds for 5 documentation sites (my-documents + 4 dependent repositories)
- Centralized configuration management with per-site overrides
- Parallel builds using GitHub Actions matrix strategy (~60s for all sites)
- GitHub App authentication for secure deployments
- Shared Hugo theme, layouts, and assets across all sites
- SEO-optimized static HTML output
- Automated linting and formatting (pre-commit hooks, MegaLinter)

**Managed Documentation Sites:**

| Site                 | Repository                      | Live URL                                             |
| -------------------- | ------------------------------- | ---------------------------------------------------- |
| My Documents         | fchastanet/my-documents         | <https://fchastanet.github.io/my-documents/>         |
| Bash Compiler        | fchastanet/bash-compiler        | <https://fchastanet.github.io/bash-compiler/>        |
| Bash Tools           | fchastanet/bash-tools           | <https://fchastanet.github.io/bash-tools/>           |
| Bash Tools Framework | fchastanet/bash-tools-framework | <https://fchastanet.github.io/bash-tools-framework/> |
| Bash Dev Env         | fchastanet/bash-dev-env         | <https://fchastanet.github.io/bash-dev-env/>         |

## Repository Structure

### Orchestrator Files (my-documents)

```text
/
├── .github/workflows/
│   ├── build-all-sites.yml          # Orchestrator workflow (builds all 5 sites)
│   ├── hugo-build-deploy.yml        # Legacy: my-documents only build
│   ├── trigger-docs-reusable.yml    # Template for dependent repos
│   └── lint.yml                     # Pre-commit linting
├── configs/
│   ├── _base.yaml                   # Shared configuration for all sites
│   ├── my-documents.yaml            # my-documents overrides
│   ├── bash-compiler.yaml           # bash-compiler overrides
│   ├── bash-tools.yaml              # bash-tools overrides
│   ├── bash-tools-framework.yaml    # bash-tools-framework overrides
│   └── bash-dev-env.yaml            # bash-dev-env overrides
├── shared/
│   ├── layouts/                     # Shared Hugo templates
│   │   └── partials/hooks/          # SEO meta tags, structured data
│   ├── assets/                      # Shared SCSS, CSS, JS
│   │   └── scss/_variables_project.scss
│   └── archetypes/                  # Content templates
│       ├── default.md
│       └── docs.md
├── content/                         # my-documents own content
│   └── en/
│       ├── _index.html              # Homepage
│       └── docs/                    # Documentation sections
│           ├── bash-scripts/
│           ├── howtos/
│           ├── lists/
│           ├── brainstorming/
│           └── other-projects/
├── static/                          # Static assets (images, downloads)
├── .cspell/                         # Custom spell-check dictionaries
├── hugo.yaml                        # Generated per build (do not manually edit)
├── go.mod                           # Go modules (Docsy theme)
├── go.sum                           # Go modules checksums
├── Makefile                         # Local development commands
└── README.md                        # User documentation
```

### Dependent Repository Structure (Example: bash-compiler)

```text
bash-compiler/
├── .github/workflows/
│   └── trigger-docs.yml             # Triggers orchestrator on content changes
├── content/en/
│   ├── _index.md                    # Homepage
│   └── docs/                        # Documentation pages
│       └── *.md
└── static/                          # Optional: site-specific static assets
    └── images/
```

**Key Differences from Standard Hugo Repos:**

- ❌ No `hugo.yaml` in dependent repos (orchestrator generates it)
- ❌ No build workflows in dependent repos (orchestrator handles builds)
- ❌ No theme files in dependent repos (shared from my-documents)
- ❌ No theme files in dependent repos (shared from my-documents)
- ✅ Only content and trigger workflow needed

## Multi-Site Orchestrator Architecture

### How It Works

1. **Content Change:** Developer pushes to dependent repository (e.g., bash-compiler)
2. **Trigger:** Trigger workflow calls `repository_dispatch` to my-documents
3. **Orchestrator Activates:** `build-all-sites.yml` workflow starts
4. **Parallel Build:** Matrix strategy builds all 5 sites simultaneously
5. **Config Merge:** Each site gets `_base.yaml` + site-specific config merged via `yq`
6. **Deploy:** GitHub App deploys each site to its respective GitHub Pages

### Build Matrix Strategy

```yaml
matrix:
  site:
    - { name: my-documents, repo: fchastanet/my-documents, self: true }
    - { name: bash-compiler, repo: fchastanet/bash-compiler, self: false }
    - { name: bash-tools, repo: fchastanet/bash-tools, self: false }
    - { name: bash-tools-framework, repo: fchastanet/bash-tools-framework, self: false }
    - { name: bash-dev-env, repo: fchastanet/bash-dev-env, self: false }
```

- `self: true` - Build from orchestrator repo itself (my-documents)
- `self: false` - Checkout and build from dependent repository

### Configuration Management

**Configuration Hierarchy:**

1. **Base Config** (`configs/_base.yaml`) - Shared across all sites:

   - Hugo modules (Docsy theme)
   - Language and i18n settings
   - Markup and syntax highlighting
   - Output formats (HTML, sitemap, RSS)
   - Default theme parameters

2. **Site-Specific Config** (`configs/[site].yaml`) - Per-site overrides:
   - Site title and baseURL
   - Theme colors (`params.ui.navbar_bg_color`)
   - Navigation menu items
   - SEO keywords and description
   - Repository links

**Merging Strategy:**

```bash
# yq deep-merge (not concatenation)
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
  configs/_base.yaml \
  configs/bash-compiler.yaml > hugo.yaml
```

**Merge Behavior:**

- Scalar values: Site-specific overrides base
- Objects: Deep merge (combined keys)
- Arrays: Site-specific replaces base entirely

### Shared Components

**Layouts and Partials** (`shared/layouts/`):

- `partials/hooks/head-end.html` - SEO meta tags, JSON-LD structured data
- Custom partials override Docsy defaults

**Assets** (`shared/assets/`):

- `scss/_variables_project.scss` - Shared SCSS variables
- Can be overridden per-site via dependent repo `static/css/`

**Archetypes** (`shared/archetypes/`):

- `default.md` - Basic page template
- `docs.md` - Documentation page template with examples

### Authentication and Deployment

**GitHub App (Preferred Method):**

- App ID: `DOC_APP_ID` secret (my-documents)
- Private Key: `DOC_APP_PRIVATE_KEY` secret (my-documents)
- Permissions: Contents (write), Pages (write)
- Installed on all 5 repositories

**Benefits over Deploy Keys:**

- Fine-grained permissions
- Automatic token expiration (1 hour)
- Centralized management (2 secrets vs 4+ deploy keys)
- Better audit trail

**Trigger Authentication:**

- Personal Access Token: `DOCS_BUILD_TOKEN` (each dependent repo)
- Scope: `repo` (for repository_dispatch)

### Local Development

**Testing Single Site:**

```bash
make build-site SITE=bash-compiler
cd build/bash-compiler
hugo server -D --port 1314
```

**Testing All Sites:**

```bash
make link-repos    # Create symlinks to dependent repos
make build-all     # Build all 5 sites
make test-all      # Build + test with curl
make unlink-repos  # Clean up symlinks
```

**Prerequisites:**

- Hugo Extended 0.155.3+
- Go 1.24+
- yq 4.0+ (for config merging)
- Dependent repos cloned side-by-side

## Git Conventions

### Branch Management

- **Default branch:** `master` (NOT main)
- Always work on the `master` branch unless explicitly instructed otherwise
- Auto-fixup branches (`update/pre-commit-*`) are created by CI for linting
  fixes
- **Commit Messages**: See
  [Commit Message Instructions](.github/commit-message.instructions.md)

### Important Note

On chat interactions, only provide the relevant changes, not the entire file
contents.

## Coding Standards

### Markdown Standards

- **Line length:**
  - MegaLinter enforces 120 characters maximum
  - mdformat wraps at 120 characters (applied via pre-commit)
- **Indentation:** 2 spaces
- **Line endings:** LF only (enforced by EditorConfig and pre-commit)
- **Headers:** Use ATX-style headers (`#`, `##`, etc.)
- **Lists:** 2-space indentation for nested items

### File Naming

- Use kebab-case for Markdown files: `HowTo-Write-Bash-Scripts.md`
- Be descriptive: filenames should clearly indicate content

### Content Guidelines

- Keep content focused and well-organized
- Use code blocks with language specification: ```` ```bash ````,
  ```` ```yaml ````, ```` ```dockerfile ````
- Add internal links using relative paths: `[text](/HowTo/guide.md)`
- External links should use full URLs

## Linting and Code Quality

### Pre-commit Hooks

Pre-commit hooks run automatically on every commit. They will:

- Format Markdown files (wrap at 120 chars)
- Fix line endings (force LF)
- Remove trailing whitespace
- Format code with Prettier
- Run markdownlint with auto-fixes
- Check for spelling errors with codespell
- Validate YAML, JSON, and XML files
- Sort spell-check dictionary files
- Detect private keys and secrets

**Key pre-commit tools:**

- `mdformat` - Markdown formatting
- `prettier` - Code formatting
- `markdownlint` - Markdown linting
- `codespell` - Spell checking

### MegaLinter

MegaLinter runs in CI and checks:

- Markdown: Link checking, linting
- Bash: ShellCheck, shfmt
- YAML: v8r validator
- JSON: jsonlint
- Spelling: cspell with custom dictionaries
- EditorConfig compliance

### Running Linters Locally

To run pre-commit hooks manually:

```bash
# Install pre-commit (if not already installed)
pip install pre-commit

# Install the git hook scripts
pre-commit install

# Run all hooks on all files
pre-commit run -a
```

### Spell Checking

- Custom dictionaries are in `.cspell/`
- Bash-specific terms are in `.cspell/bash.txt`
- To add new words, update the appropriate dictionary file
- Keep dictionary files sorted alphabetically (pre-commit enforces this)

### Common Linting Issues and Solutions

| Issue                       | Solution                                           |
| --------------------------- | -------------------------------------------------- |
| Line too long (MD013)       | Let mdformat auto-wrap at 120 chars                |
| Trailing whitespace         | Pre-commit hook removes automatically              |
| Wrong line endings          | Pre-commit fixes to LF                             |
| Spelling errors             | Add to `.cspell/*.txt` dictionaries                |
| Markdown formatting         | Run `pre-commit run mdformat -a`                   |
| Link check failures         | Verify URLs or add to ignore list                  |
| Heading levels inconsistent | Run `pre-commit run markdown-heading-numbering -a` |
| Toc missing or outdated     | Run `pre-commit run mdformat-toc -a`               |

## CI/CD Workflows

### lint.yml (Pre-commit Run)

- **Triggers:** Push to any branch, tags, manual dispatch
- **What it does:**
  - Runs pre-commit hooks on all files
  - Runs MegaLinter with documentation flavor
  - Creates auto-fix PRs if changes needed (unless commit contains "skip fix")
  - Uses GPG signing for commits
- **Concurrency:** Cancels previous builds on new push
- **Artifacts:** MegaLinter reports and logs

### hugo-build-deploy.yml (Hugo Build & Deploy)

- **Triggers:** Push to master, manual dispatch
- **What it does:**
  - Builds static site using Hugo with Docsy theme
  - Downloads Hugo modules (Docsy and dependencies)
  - Minifies output for optimal performance
  - Validates build output
  - Deploys to GitHub Pages
- **Cache:** Caches Hugo modules for faster builds
- **Prerequisites:** Uses Hugo extended with Go support

### Other Workflows

- `precommit-autoupdate.yml` - Auto-updates pre-commit hook versions
- `set-github-status-on-pr-approved.yml` - Sets status on PR approval
- Dependabot - Creates PRs for dependency updates

## Development Workflow

### Local Setup

1. **Install Hugo Extended:**

   ```bash
   # Linux
   CGO_ENABLED=1 go install -tags extended github.com/gohugoio/hugo@latest
   ```

   Verify: `hugo version` (should show 0.155+)

2. **Clone repository and setup:**

   ```bash
   git clone https://github.com/fchastanet/my-documents.git
   cd my-documents
   hugo mod get -u
   ```

3. **Run local server:**

   ```bash
   hugo server -D
   ```

   Open <http://localhost:1313/my-documents/> in browser (auto-reloads on file changes)

### Making Content Changes

1. **Edit or create Markdown files** in `content/en/docs/` subdirectories

2. **Add frontmatter to new pages:**

   ```yaml
   ---
   title: Page Title
   description: Brief description
   weight: 10
   ---

   Your content here...
   ```

3. **Local preview:**

   ```bash
   hugo server -D
   # Site auto-reloads at http://localhost:1313/my-documents/
   ```

4. **Commit changes:**

   ```bash
   git add .
   git commit -m "Add/update documentation"
   ```

   Note: Pre-commit hooks will auto-format your changes

5. **Push to trigger CI:**

   ```bash
   git push origin master
   ```

6. **Review CI results:**

   - Check GitHub Actions for lint workflow status
   - Check GitHub Actions for hugo-build-deploy status
   - If auto-fixes are needed, a PR will be created automatically
   - Merge the auto-fix PR if appropriate

### Adding New Documentation

1. **Create new Markdown file** in appropriate `content/en/docs/` subdirectory

   ```bash
   hugo new docs/section/page-name.md
   ```

2. **Add frontmatter:**

   ```yaml
   ---
   title: My New Page
   description: Brief description of the page
   weight: 10
   categories: [documentation]
   tags: [example]
   ---
   ```

3. **Write content** using Markdown with optional Docsy shortcodes

4. **Test locally:** `hugo server -D` and verify at <http://localhost:1313/my-documents/>

5. **Commit and push**

### Updating Configuration

**Hugo configuration** (`hugo.yaml`):

- Site title, description, keywords
- Menu structure (main menu and footer)
- Theme parameters and Docsy settings
- Output formats (HTML, JSON, RSS)
- SEO parameters

**Linter configuration:**

| File                      | Purpose                                          |
| ------------------------- | ------------------------------------------------ |
| `.editorconfig`           | Editor configuration (indentation, line endings) |
| `.eslintrc.js`            | ESLint configuration for JavaScript files        |
| `.gitignore`              | Files to exclude from version control            |
| `.markdownlint.json`      | Markdown linting rules                           |
| `.mega-linter.yml`        | MegaLinter configuration                         |
| `.pre-commit-config.yaml` | Pre-commit hooks configuration                   |
| `.prettierrc.yaml`        | Prettier formatting rules                        |
| `cspell.yaml`             | Spell check configuration                        |
| `.gitleaks.toml`          | Secret detection configuration                   |
| `.secretlintrc.yml`       | Secret pattern detection                         |

## Testing Changes

### Local Testing Checklist

- [ ] Run `hugo server -D` without errors
- [ ] All pages render correctly locally
- [ ] All internal links work
- [ ] Code blocks have proper syntax highlighting
- [ ] Images display correctly
- [ ] Menu navigation works as expected
- [ ] Mobile responsiveness looks good
- [ ] Spell check passes (or new words added to dictionary)
- [ ] No trailing whitespace or wrong line endings
- [ ] Pre-commit hooks pass

### Build Validation

```bash
# Build site and check for errors
hugo --minify

# Verify public directory was created
ls -la public/

# Check for common issues
hugo --printI18nWarnings --printPathWarnings --printUnusedTemplates
```

### CI Testing

After pushing, verify:

- [ ] Pre-commit workflow passes (lint.yml)
- [ ] Hugo build & deploy workflow passes (hugo-build-deploy.yml)
- [ ] MegaLinter checks pass
- [ ] GitHub Pages deployment succeeds (for master branch)
- [ ] Live site renders correctly: <https://fchastanet.github.io/my-documents/>

## Working with the Orchestrator

### Adding a New Documentation Site

**Checklist:**

1. **In dependent repository:**
   - [ ] Create `content/en/docs/` structure
   - [ ] Add `content/en/_index.md` (homepage)
   - [ ] Add `.github/workflows/trigger-docs.yml`
   - [ ] Add `DOCS_BUILD_TOKEN` secret
2. **In my-documents repository:**
   - [ ] Create `configs/[new-site].yaml` with site-specific config
   - [ ] Add site to matrix in `.github/workflows/build-all-sites.yml`
   - [ ] Install GitHub App on new repository
3. **Testing:**
   - [ ] Test locally: `make build-site SITE=new-site`
   - [ ] Push to trigger CI build
   - [ ] Verify deployment to GitHub Pages

### Updating Shared Components

**Impact Analysis:**

- Changes to `shared/layouts/` affect **all sites**
- Changes to `shared/assets/` affect **all sites**
- Changes to `configs/_base.yaml` affect **all sites**
- Changes to `configs/[site].yaml` affect **one site only**

**Testing Strategy:**

```bash
# Test change across all sites before committing
make build-all

# Verify each site individually
for site in my-documents bash-compiler bash-tools bash-tools-framework bash-dev-env; do
  echo "Testing $site..."
  make build-site SITE=$site
done
```

**Common Changes:**

| Task                       | Files to Edit                                       | Impact         |
| -------------------------- | --------------------------------------------------- | -------------- |
| Update Hugo theme version  | `configs/_base.yaml` (module version)               | All sites      |
| Add SEO feature            | `shared/layouts/partials/hooks/head-end.html`       | All sites      |
| Change site-specific color | `configs/[site].yaml` (params.ui.navbar_bg_color)   | One site       |
| Add new archetype          | `shared/archetypes/new-template.md`                 | All sites      |
| Update base SCSS           | `shared/assets/scss/_variables_project.scss`        | All sites      |

### Configuration Deep-Dive

**Base Config Keys** (`configs/_base.yaml`):

- `baseURL` - Overridden per site
- `title` - Overridden per site
- `module.mounts` - Shared resources (layouts, assets, archetypes)
- `params.ui` - UI defaults (colors, sidebar, navbar)
- `params.search` - Search configuration
- `markup` - Markdown rendering, syntax highlighting
- `outputs` - Output formats (HTML, RSS, sitemap)

**Site-Specific Override Examples:**

```yaml
# bash-compiler.yaml
baseURL: https://fchastanet.github.io/bash-compiler
title: Bash Compiler Documentation
params:
  description: "Documentation for Bash Compiler"
  ui:
    navbar_bg_color: "#007bff" # Blue theme
  github_repo: https://github.com/fchastanet/bash-compiler
```

### Troubleshooting Orchestrator Issues

**Build Fails for All Sites:**

1. Check Hugo version in workflow (0.155.3)
2. Validate `configs/_base.yaml` syntax: `yq eval configs/_base.yaml`
3. Check GitHub Actions logs for setup errors
4. Verify yq installation succeeded

**Build Fails for One Site:**

1. Validate site config: `yq eval configs/[site].yaml`
2. Test config merge locally:
   ```bash
   yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
     configs/_base.yaml configs/[site].yaml
   ```
3. Check content frontmatter in dependent repo
4. Check for broken internal links

**Deployment Fails:**

1. Verify GitHub App installed on repository
2. Check `DOC_APP_ID` and `DOC_APP_PRIVATE_KEY` secrets exist
3. Verify app permissions: Contents (write), Pages (write)
4. Check gh-pages branch created in dependent repo

**Site Not Updating:**

1. Wait 2-3 minutes for GitHub Pages propagation
2. Check workflow completed successfully
3. Clear browser cache
4. Verify GitHub Pages settings: Deploy from gh-pages branch

### Best Practices for AI Agents

**When Editing Shared Components:**

1. Always test across all sites before committing
2. Document changes in commit message
3. Alert user if change may break existing sites
4. Provide rollback instructions

**When Adding New Site:**

1. Follow checklist in Section "Adding a New Documentation Site"
2. Choose unique theme color for site
3. Test locally before pushing
4. Verify all links and assets work

**When Debugging:**

1. Identify which component failed (trigger, build, or deploy)
2. Check appropriate logs (dependent repo or orchestrator)
3. Reproduce locally when possible
4. Provide specific solution based on error

## Troubleshooting

### Hugo Server Won't Start

**Symptom:** `hugo server -D` fails with module errors

**Solution:**

```bash
# Clear Hugo module cache and re-download
rm go.sum
hugo mod clean
hugo mod get -u
hugo server -D
```

### Build Fails with Missing Modules

**Symptom:** Build error about missing `github.com/google/docsy`

**Solution:**

```bash
# Ensure Hugo extended is installed
hugo version  # Should show "extended"

# Download modules
hugo mod get -u

# Try building again
hugo --minify
```

### Pre-commit Hook Failures

**Symptom:** Commit fails with pre-commit errors

**Solution:**

```bash
# Let pre-commit auto-fix what it can
pre-commit run -a

# Review changes
git diff

# Add fixed files and commit again
git add .
git commit -m "Your message"
```

### MegaLinter Failures in CI

**Symptom:** MegaLinter workflow fails in GitHub Actions

**Solution:**

1. Download MegaLinter artifacts from workflow run
2. Review `megalinter-reports/` for specific errors
3. Fix issues locally
4. Run `pre-commit run -a` to verify fixes
5. Push corrected changes

### Spelling Errors

**Symptom:** cspell or codespell report unknown words

**Solution:**

```bash
# For technical terms, add to bash dictionary
echo "newWord" >> .cspell/bash.txt

# Sort the dictionary (pre-commit will do this)
pre-commit run file-contents-sorter

# Commit the updated dictionary
git add .cspell/bash.txt
git commit -m "Add 'newWord' to spell check dictionary"
```

### GitHub Pages Not Updating

**Symptom:** Changes pushed but site not updating

**Solution:**

1. Check `hugo-build-deploy` workflow status in Actions
2. Verify changes were pushed to `master` branch
3. Check that workflow completed successfully
4. Clear browser cache and retry
5. Check GitHub Pages settings in repository settings (should deploy from "gh-pages" branch)

### Auto-fix PR Created Unexpectedly

**Symptom:** CI creates auto-fix PR for your changes

**Solution:**

1. Review the auto-fix PR changes
2. If acceptable, merge the PR
3. Pull the changes locally: `git pull origin master`
4. To skip auto-fixes in future, include "skip fix" in commit message

## Common Patterns

### Adding a New Documentation Page

1. Create file in appropriate section:

   ```bash
   hugo new docs/bash-scripts/my-new-page.md
   # or
   hugo new docs/howtos/my-guide.md
   ```

2. Edit the file with frontmatter and content:

   ```yaml
   ---
   title: My New Page
   description: Brief description for SEO
   weight: 10
   categories: [bash-scripting]
   tags: [bash, scripts]
   ---

   Your Markdown content...
   ```

3. Navigation is automatic based on directory structure and weight

4. Test locally: `hugo server -D`

5. Commit and push

### Adding Code Examples

Use proper code fencing with language specification:

````markdown
```bash
#!/bin/bash
set -euo pipefail

echo "Hello, World!"
```
````

### Using Docsy Shortcodes

Hugo/Docsy provides helpful shortcodes for structured content:

```markdown
{{% pageinfo color="primary" %}}
This is a highlighted info box.
{{% /pageinfo %}}

{{% alert title="Warning" color="warning" %}}
This is a warning message.
{{% /alert %}}
```

### Adding Images

1. Place image in `static/` directory (or appropriate subdirectory)

2. Reference in Markdown:

   ```markdown
   ![Alt text](/images/diagram.png)
   ```

3. Ensure image is optimized (Hugo processes images)

### Creating Cross-References

Use relative paths for internal links (Hugo will resolve them):

```markdown
See also: [Bash Best Practices](/docs/bash-scripts/basic-best-practices/)

Or with descriptive text:
[Learn more about Docker](/docs/howtos/howto-write-dockerfile/)
```

### Organizing Content

Place related content in subdirectories:

```text
content/en/docs/
├── bash-scripts/
│   ├── _index.md
│   ├── basic-best-practices.md
│   ├── linux-commands-best-practices.md
│   └── bats-best-practices.md
├── howtos/
│   ├── _index.md
│   ├── howto-write-jenkinsfile/
│   │   ├── _index.md
│   │   └── related-content.md
│   └── howto-write-dockerfile.md
```

Use `weight` in frontmatter to control ordering within sections.

## Tools and Dependencies

### Required Tools (for local development)

- Git
- Hugo Extended v0.110+ (with Go support)
- Go 1.18+
- Python 3.10+ (for pre-commit)

### Optional Tools

- `pre-commit` - Git hook framework
- Docker (for MegaLinter local runs)

### Hugo Modules

- `github.com/google/docsy` - Docsy theme
- `github.com/google/docsy/dependencies` - Docsy dependencies

## Best Practices

### Do's

- ✅ Use pre-commit hooks (let them auto-fix formatting)
- ✅ Keep Markdown files focused and well-organized
- ✅ Add new technical terms to spell check dictionaries
- ✅ Test changes locally before pushing
- ✅ Update navigation when adding new content
- ✅ Use descriptive commit messages in Markdown format
- ✅ Keep line lengths under 120 characters
- ✅ Use relative links for internal references

### Don'ts

- ❌ Don't manually format Markdown (let mdformat do it)
- ❌ Don't use CRLF line endings (always LF)
- ❌ Don't commit without running pre-commit hooks
- ❌ Don't add large binary files without optimization
- ❌ Don't use absolute URLs for internal links
- ❌ Don't bypass CI checks
- ❌ Don't commit secrets or credentials
- ❌ Don't ignore spelling errors (add words to dictionary instead)

## Security Considerations

- **Secret detection:** Gitleaks and Secretlint scan for secrets
- **Never commit:** API keys, passwords, tokens, private keys
- **Safe practices:**
  - Use placeholders in examples: `your-api-key-here`
  - Review changes before committing: `git diff`
  - Check CI for security alerts

## Additional Resources

- [Hugo Documentation](https://gohugo.io/documentation/)
- [Docsy Theme Documentation](https://www.docsy.dev/)
- [MegaLinter Documentation](https://megalinter.io/)
- [Pre-commit Documentation](https://pre-commit.com/)
- [Markdown Guide](https://www.markdownguide.org/)

## Summary for Coding Agents

When working on this repository:

1. **Repository Type:** Multi-site orchestrator + own documentation
2. **Branch:** Always use `master`
3. **Commit messages:** Detailed Markdown format with title and changes list
4. **Linting:** Pre-commit hooks auto-fix most issues
5. **Line length:** 120-character wrapping for Markdown
6. **Spell checking:** Add technical terms to `.cspell/bash.txt`
7. **Navigation:** Automatic from directory structure and frontmatter weight
8. **Testing:** Build locally with `hugo server -D` and verify at <http://localhost:1313/my-documents/>
9. **Content location:** Place all content in `content/en/docs/` subdirectories
10. **Frontmatter:** Always include title, description, and weight
11. **CI/CD:** Workflows handle linting and deployment automatically
12. **On chat:** Only provide relevant changes, not entire files

**Orchestrator-Specific:**

13. **Shared components impact all sites** - Test thoroughly before committing changes to `shared/`
14. **Config changes:** Base config affects all sites, site-specific affects one
15. **Adding sites:** Follow complete checklist (configs/, workflow matrix, GitHub App, secrets)
16. **Build testing:** Use `make build-all` to test all sites locally
17. **Config merging:** Use `yq` for deep-merge, validate syntax before committing
18. **Authentication:** GitHub App for deployment, PAT for triggers
19. **Parallel builds:** All 5 sites build simultaneously (~60s total)
20. **Deployment:** Fully automated via GitHub Actions to respective GitHub Pages
