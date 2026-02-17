# Copilot Instructions for my-documents Repository

## Repository Overview

This is a **documentation repository** built with **Hugo** static site generator
and the **Docsy** theme. It is published to GitHub Pages at
<https://fchastanet.github.io/my-documents/>. It contains technical
documentation and HowTo guides on Bash scripting, Docker, Jenkins, and various
development topics.

**Key characteristics:**

- Static documentation site built with Hugo (fast, SEO-optimized)
- Docsy theme for professional, responsive documentation design
- All content in Markdown files with optional YAML frontmatter
- Extensive linting and formatting automation
- Automatic GitHub Pages deployment on push to master
- Optimized for search engine indexing (SEO)
- Static HTML output (no JavaScript required for functionality)

## Repository Structure

```text
/
├── content/                     # All Markdown content
│   └── en/                      # English language content
│       ├── _index.html          # Home page
│       ├── docs/                # Documentation sections
│       │   ├── _index.md        # Docs landing page
│       │   ├── bash-scripts/    # Bash scripting guides
│       │   ├── howtos/          # How-to guides
│       │   ├── lists/           # Reference lists
│       │   └── other-projects/  # Links to related projects
├── HowTo/                       # Legacy content (to be migrated)
├── Lists/                       # Legacy content (to be migrated)
├── static/                      # Static assets (images, downloads, etc.)
├── archetypes/                  # Content templates
│   ├── default.md               # Default page archetype
│   └── docs.md                  # Docs page archetype
├── assets/                      # CSS/SCSS overrides
├── images/                      # Legacy images directory
├── .github/
│   ├── workflows/               # CI/CD automation
│   │   ├── lint.yml             # Pre-commit linting
│   │   └── hugo-build-deploy.yml # Hugo build & deploy
│   └── copilot-instructions.md  # This file
├── .cspell/                     # Custom spell-check dictionaries
├── hugo.yaml                    # Hugo configuration
├── go.mod                       # Go modules (Docsy theme)
├── go.sum                       # Go modules checksums
└── README.md                    # Repository landing page
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
   # macOS
   brew install hugo

   # Linux
   sudo apt-get install hugo

   # Windows
   choco install hugo-extended
   ```

   Verify: `hugo version` (should show 0.110+)

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

4. **Test locally:** `hugo server -D` and verify at http://localhost:1313/my-documents/

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
See also: [Bash Best Practices](/docs/bash-scripts/basic-bestpractices/)

Or with descriptive text:
[Learn more about Docker](/docs/howtos/howto-write-dockerfile/)
```

### Organizing Content

Place related content in subdirectories:

```
content/en/docs/
├── bash-scripts/
│   ├── _index.md
│   ├── basic-bestpractices.md
│   ├── linuxcommands-bestpractices.md
│   └── bats-bestpractices.md
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

1. **Branch:** Always use `master`
2. **Commit messages:** Detailed Markdown format with title and changes list
3. **Linting:** Pre-commit hooks auto-fix most issues
4. **Line length:** 120-character wrapping for Markdown
5. **Spell checking:** Add technical terms to `.cspell/bash.txt`
6. **Navigation:** Automatic from directory structure and frontmatter weight
7. **Testing:** Build locally with `hugo server -D` and verify at <http://localhost:1313/my-documents/>
8. **Content location:** Place all content in `content/en/docs/` subdirectories
9. **Frontmatter:** Always include title, description, and weight
10. **CI/CD:** Workflows handle linting and deployment automatically
11. **On chat:** Only provide relevant changes, not entire files
