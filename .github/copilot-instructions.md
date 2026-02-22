# Copilot Instructions for my-documents Repository

## Repository Overview

This is a **public repository providing a reusable GitHub Action** for building and deploying Hugo documentation sites
using the **Docsy** theme.

**Primary Purpose:** Provide shared Hugo resources and reusable build action for related Bash tooling projects

**Key Characteristics:**

- Provides reusable GitHub Action for independent site builds
- Shared Hugo resources via Hugo Go modules (layouts, assets, archetypes)
- Base configuration template for consistent site setup
- Standard GITHUB_TOKEN authentication (no secrets required)
- SEO-optimized static HTML output
- Automated linting and formatting (pre-commit hooks, MegaLinter)

**Documentation Sites Using This Action:**

| Site                 | Repository                      | Live URL                                             |
| -------------------- | ------------------------------- | ---------------------------------------------------- |
| My Documents         | fchastanet/my-documents         | <https://fchastanet.github.io/my-documents/>         |
| Bash Compiler        | fchastanet/bash-compiler        | <https://fchastanet.github.io/bash-compiler/>        |
| Bash Tools           | fchastanet/bash-tools           | <https://fchastanet.github.io/bash-tools/>           |
| Bash Tools Framework | fchastanet/bash-tools-framework | <https://fchastanet.github.io/bash-tools-framework/> |
| Bash Dev Env         | fchastanet/bash-dev-env         | <https://fchastanet.github.io/bash-dev-env/>         |

## Repository Structure

### Reusable Action Repository (my-documents)

```text
/
├── .github/workflows/
│   ├── build-site.yml               # my-documents site build workflow
│   ├── build-site-action.yml        # Reusable action (called by dependent repos)
│   └── lint.yml                     # Pre-commit linting
├── configs/
│   ├── _base.yaml                   # Base configuration template (imported by sites via Hugo modules)
│   └── site-config.yaml             # Site-specific configuration (overrides base) - each site has its own
├── shared/
│   ├── layouts/                     # Shared Hugo templates (available via Hugo modules)
│   │   └── partials/hooks/          # SEO meta tags, structured data
│   ├── assets/                      # Shared SCSS, CSS, JS (available via Hugo modules)
│   │   └── scss/_variables_project.scss
│   └── archetypes/                  # Content templates (available via Hugo modules)
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
├── hugo.yaml                        # generated Hugo configuration from configs/_base.yaml + site-config.yaml
│                                    #   (non committed, generated at build time)
├── go.mod                           # Go modules (Docsy theme + shared resources)
├── go.sum                           # Go modules checksums
├── Makefile                         # Local development commands
└── README.md                        # User documentation
```

### Dependent Repository Structure (Example: bash-compiler)

```text
bash-compiler/
├── .github/workflows/
│   └── build-site.yml               # Calls reusable action from my-documents
├── content/
│   ├── _index.md                    # Homepage
│   └── docs/                        # Documentation pages
│       └── *.md
├── static/                          # Optional: site-specific static assets
│   └── images/
├── configs/
│   └── site-config.yaml             # Site-specific Hugo configuration (imports base via Hugo modules)
├── go.mod                           # Hugo modules (my-documents for shared resources)
└── go.sum                           # Hugo modules checksums
```

**Key Differences from Standard Hugo Repos:**

- ✅ Each repo has `hugo.yaml` (imports base config via Hugo modules)
- ✅ Each repo has `build-site.yml` (calls reusable action)
- ✅ Each repo has `go.mod` (Hugo modules for shared resources)
- ✅ Content + configuration + workflow needed
- ❌ No theme files in dependent repos (shared via Hugo modules from my-documents)

## Reusable Action Architecture

### How It Works

1. **Content Change:** Developer pushes to dependent repository (e.g., bash-compiler)
2. **Build Workflow:** Repository's `build-site.yml` workflow activates on push to master
3. **Call Reusable Action:** Workflow calls `fchastanet/my-documents/.github/workflows/build-site-action.yml`
4. **Build Site:** Reusable action builds the Hugo site using repo's `hugo.yaml` and content
5. **Deploy:** Uses standard GITHUB_TOKEN to deploy to GitHub Pages (gh-pages branch)

### Reusable Action Parameters

The `build-site-action.yml` accepts these inputs:

- `hugo-version` - Hugo version to use (default: 0.155.3)
- `node-version` - Node.js version for asset processing (default: 20)
- `working-directory` - Directory containing Hugo site (default: .)

**Standard GITHUB_TOKEN is used automatically** - no secrets configuration needed.

### Hugo Modules for Resource Sharing

Dependent repositories import shared resources from my-documents via Hugo modules:

**In dependent repo's `hugo.yaml`:**

```yaml
module:
  imports:
    # Import shared resources from my-documents
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
    # Import Docsy theme
    - path: github.com/google/docsy
    - path: github.com/google/docsy/dependencies
```

**Benefits:**

- Automatic updates when my-documents shared resources change
- Version control via go.mod (can pin to specific commit/tag)
- No duplication of layouts, assets, archetypes
- Each site maintains independence (can override any shared resource)

### Configuration Management

**Configuration Approach:**

1. **Base Config** (`configs/_base.yaml` in my-documents) - Imported via Hugo modules:

   - Hugo modules (Docsy theme)
   - Language and i18n settings
   - Markup and syntax highlighting
   - Output formats (HTML, sitemap, RSS)
   - Default theme parameters

2. **Site-Specific Config** (each repo's `configs/site-config.yaml`) - Imports base and adds overrides:
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
  configs/site-config.yaml > hugo.yaml
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

**Standard GITHUB_TOKEN (Automatic):**

- Automatically provided by GitHub Actions
- No secrets configuration required
- Sufficient permissions for:
  - Reading repository content
  - Deploying to GitHub Pages (using github-pages action)
  - Creating releases and tags

**GitHub Pages Setup:**

Each repository must configure GitHub Pages to use Github Actions deployment:

1. Go to repository Settings → Pages
2. Set Source to "GitHub Actions", the workflow `.github/workflows/build-site.yml` will handle deployment to `gh-pages` branch
4. Save settings

The reusable action handles creating/updating the `gh-pages` branch automatically.

### Local Development

**Testing my-documents Site:**

```bash
make start
# Opens at http://localhost:1313/my-documents/
```

**Testing Dependent Site (e.g., bash-compiler):**

```bash
# In the dependent repo directory
SITE=bash-compiler make start-site
# Opens at http://localhost:1313/bash-compiler/
```

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

### .github/workflows/build-site.yml (Hugo Build & Deploy)

- **Triggers:** Push to master, manual dispatch
- **What it does:**
   - uses `.github/workflows/build-site-action.yml` reusable action to build and deploy the site that will:
      - Builds static site using Hugo with Docsy theme
      - Downloads Hugo modules (Docsy and dependencies)
      - Minifies output for optimal performance
      - Validates build output
      - Deploys to GitHub Pages
- **Cache:** Caches Hugo modules for faster builds
- **Prerequisites:** Uses Hugo extended with Go support

### Other Workflows

- `.github/workflows/build-site-action.yml` - Reusable action for building and deploying Hugo sites (called by dependent repos)
- `.github/workflows/lint.yml` - Runs pre-commit hooks and MegaLinter checks on push
- `.github/workflows/precommit-autoupdate.yml` - Auto-updates pre-commit hook versions
- `.github/workflows/set-github-status-on-pr-approved.yml` - Sets status on PR approval
- Dependabot - Creates PRs for dependency updates

## Development Workflow

### Local Setup

1. **Clone repository and setup:**

   ```bash
   git clone https://github.com/fchastanet/my-documents.git
   cd my-documents
   make install
   ```

2. **Run local server:**

   ```bash
   make start
   ```

   Open <http://localhost:1313/my-documents/> in browser (auto-reloads on file changes)

### Making Content Changes

1. **Edit or create Markdown files** in `content/docs/` subdirectories

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
   make start
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
   - Check GitHub Actions for build-site status
   - If auto-fixes are needed, a PR will be created automatically
   - Merge the auto-fix PR if appropriate

### Adding New Documentation

1. **Create new Markdown file** in appropriate `content/docs/` subdirectory

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
- [ ] Hugo build & deploy workflow passes (build-site.yml)
- [ ] MegaLinter checks pass
- [ ] GitHub Pages deployment succeeds (for master branch)
- [ ] Live site renders correctly: <https://fchastanet.github.io/my-documents/>

## Working with the Reusable Action

### Adding a New Documentation Site

**Checklist:**

1. **In dependent repository:**
   - [ ] Create `content/docs/` structure
   - [ ] Add `content/_index.md` (homepage)
   - [ ] Create `hugo.yaml` with base config import
   - [ ] Create `go.mod` with Hugo modules
   - [ ] Add `.github/workflows/build-site.yml` (calls reusable action)
   - [ ] Configure GitHub Pages: Settings → Pages → Deploy from gh-pages branch
2. **In my-documents repository:**
   - [ ] No changes needed (resources shared via Hugo modules)
3. **Testing:**
   - [ ] Test locally: `hugo server -D` in dependent repo
   - [ ] Push to trigger CI build
   - [ ] Verify deployment to GitHub Pages

### Updating Shared Components

**Impact Analysis:**

- Changes to `shared/layouts/` affect **all sites** (via Hugo modules)
- Changes to `shared/assets/` affect **all sites** (via Hugo modules)
- Changes to `configs/_base.yaml` affect **all sites** (via Hugo modules)
- Changes to site's `hugo.yaml` affect **one site only**

**Testing Strategy:**

```bash
# Test my-documents site
hugo server -D

# For dependent sites, test in their repo:
SITE=bash-compiler make start-site
```

**Common Changes:**

| Task                       | Files to Edit                                     | Impact   |
| -------------------------- | ------------------------------------------------- | -------- |
| Update Hugo theme version  | `configs/_base.yaml` (module version)             | All sites |
| Add SEO feature            | `shared/layouts/partials/hooks/head-end.html`     | All sites |
| Change site-specific color | Site's `hugo.yaml` (params.ui.navbar_bg_color)    | One site |
| Add new archetype          | `shared/archetypes/new-template.md`               | All sites |
| Update base SCSS           | `shared/assets/scss/_variables_project.scss`      | All sites |

### Configuration Deep-Dive

**Base Config Keys** (`configs/_base.yaml`):

- `baseURL` - Overridden per site
- `title` - Overridden per site
- `module.imports` - Docsy theme modules
- `params.ui` - UI defaults (colors, sidebar, navbar)
- `params.search` - Search configuration
- `markup` - Markdown rendering, syntax highlighting
- `outputs` - Output formats (HTML, RSS, sitemap)

**Site-Specific Override Examples:**

```yaml
# In dependent repo's hugo.yaml
# inherits from base config (see configs/_base.yaml)
baseURL: https://fchastanet.github.io/bash-compiler
title: Bash Compiler Documentation

params:
  description: "Documentation for Bash Compiler"
  ui:
    navbar_bg_color: "#007bff" # Blue theme
  github_repo: https://github.com/fchastanet/bash-compiler
```

### Troubleshooting Reusable Action Issues

**Build Fails for All Sites:**

1. Check Hugo version in workflow (0.155.3)
2. Validate `configs/_base.yaml` syntax: `hugo config`
3. Check GitHub Actions logs for setup errors
4. Verify Hugo modules are accessible

**Build Fails for One Site:**

1. Validate site config: `hugo config` in dependent repo
2. Test Hugo modules locally:
   ```bash
   hugo mod clean
   hugo mod get -u
   ```
3. Check content frontmatter in dependent repo
4. Check for broken internal links

**Deployment Fails:**

1. Verify GitHub Pages is enabled in repository settings
2. Check GITHUB_TOKEN permissions (automatic, should just work)
3. Verify gh-pages branch created in dependent repo
4. Check workflow logs for deployment errors

**Site Not Updating:**

1. Wait 2-3 minutes for GitHub Pages propagation
2. Check workflow completed successfully
3. Clear browser cache
4. Verify GitHub Pages settings: Deploy from gh-pages branch

**Hugo Modules Not Loading:**

1. Clear module cache: `hugo mod clean`
2. Update modules: `hugo mod get -u`
3. Verify `go.mod` exists and is valid
4. Check internet connectivity (modules downloaded from GitHub)

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

1. Identify which component failed (build or deploy)
2. Check appropriate logs (GitHub Actions workflow)
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
# lint spelling errors with cspell
npx cspell --quiet .

# debug what dictionary is loaded
npx cspell --debug --quiet .

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

1. Check `build-site` workflow status in Actions
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
content/docs/
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
- Hugo Extended 0.155.3+ (with Go support)
- Go 1.24+ (for Hugo modules)
- Python 3.12+ (for pre-commit)
- Internet connection (for downloading Hugo modules)

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

1. **Repository Type:** Reusable action provider + own documentation
2. **Branch:** Always use `master`
3. **Commit messages:** Detailed Markdown format with title and changes list
4. **Linting:** Pre-commit hooks auto-fix most issues
5. **Line length:** 120-character wrapping for Markdown
6. **Spell checking:** Add technical terms to `.cspell/bash.txt`
7. **Navigation:** Automatic from directory structure and frontmatter weight
8. **Testing:** Build locally with `hugo server -D` and verify at <http://localhost:1313/my-documents/>
9. **Content location:** Place all content in `content/docs/` subdirectories
10. **Frontmatter:** Always include title, description, and weight
11. **CI/CD:** Workflows handle linting and deployment automatically
12. **On chat:** Only provide relevant changes, not entire files

**Reusable Action-Specific:**

13. **Shared components impact all sites** - Test thoroughly before committing changes to `shared/`
14. **Config changes:** Base config affects all sites, site-specific affects one
15. **Adding sites:** Follow complete checklist (content, hugo.yaml, go.mod, build-site.yml, GitHub Pages)
16. **Build testing:** Test in each repo with `hugo server -D`
17. **Config merging:** Hugo handles via module imports, no manual yq needed
18. **Authentication:** Standard GITHUB_TOKEN (automatic, no secrets)
19. **Independent builds:** Each site builds on its own schedule
20. **Deployment:** Fully automated via reusable action to respective GitHub Pages
