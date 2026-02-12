# Copilot Instructions for my-documents Repository

## Repository Overview

This is a **documentation repository** built with **Docsify** and published to
GitHub Pages at <https://fchastanet.github.io/my-documents/>. It contains
technical documentation and HowTo guides on Bash scripting, Docker, Jenkins, and
various development topics.

**Key characteristics:**

- Static documentation site using Docsify (no build step required)
- All content in Markdown files
- Extensive linting and formatting automation
- GitHub Pages deployment on push to master

## Repository Structure

```text
/
├── HowTo/                  # Tutorial articles (Bash, Docker, Jenkins, etc.)
│   ├── HowTo-Write-Bash-Scripts/
│   ├── HowTo-Write-Dockerfile/
│   └── HowTo-Write-Jenkinsfile/
├── Lists/                  # Reference lists (Test, Web)
├── images/                 # Static assets
├── archives/               # Archived content
├── .github/
│   ├── workflows/          # CI/CD automation
│   └── copilot-instructions.md  # This file
├── .cspell/                # Custom spell-check dictionaries
├── index.html              # Docsify configuration
├── _sidebar.md             # Navigation sidebar
├── _navbar.md              # Top navigation bar
└── README.md               # Repository landing page
```

## Git Conventions

### Branch Management

- **Default branch:** `master` (NOT main)
- Always work on the `master` branch unless explicitly instructed otherwise
- Auto-fixup branches (`update/pre-commit-*`) are created by CI for linting
  fixes

### Commit Messages

Commit messages must follow these standards:

- **Format:** Markdown format
- **Structure:**
  - Title line summarizing the changes
  - Detailed description containing every relevant change (not just a summary)
  - For GitHub workflows: split lines longer than 120 characters

**Example:**

```markdown
# Add new section on Docker networking

## Changes

- Added comprehensive guide on Docker networking modes
- Updated sidebar navigation to include new section
- Fixed typos in existing Docker documentation
- Added diagrams for bridge and host networking
```

### Important Note

On chat interactions, only provide the relevant changes, not the entire file
contents.

## Coding Standards

### Markdown Standards

- **Line length:**
  - MegaLinter enforces 120 characters maximum
  - mdformat wraps at 80 characters (applied via pre-commit)
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

- Format Markdown files (wrap at 80 chars)
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

| Issue                 | Solution                              |
| --------------------- | ------------------------------------- |
| Line too long (MD013) | Let mdformat auto-wrap at 80 chars    |
| Trailing whitespace   | Pre-commit hook removes automatically |
| Wrong line endings    | Pre-commit fixes to LF                |
| Spelling errors       | Add to `.cspell/*.txt` dictionaries   |
| Markdown formatting   | Run `pre-commit run mdformat -a`      |
| Link check failures   | Verify URLs or add to ignore list     |

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

### docsify-gh-pages.yml (Deploy Docsify)

- **Triggers:** Push to master, manual dispatch
- **What it does:**
  - Builds Docsify site
  - Deploys to GitHub Pages
- **No build step required:** Docsify renders Markdown client-side

### Other Workflows

- `precommit-autoupdate.yml` - Auto-updates pre-commit hook versions
- `set-github-status-on-pr-approved.yml` - Sets status on PR approval
- Dependabot - Creates PRs for dependency updates

## Development Workflow

### Making Content Changes

1. **Edit or create Markdown files** in appropriate directories (`HowTo/`,
   `Lists/`, etc.)

2. **Update navigation if needed:**

   - Edit `_sidebar.md` to add new pages to sidebar
   - Edit `_navbar.md` for top navigation changes

3. **Local preview (optional):**

   ```bash
   # Install docsify-cli
   npm i -g docsify-cli

   # Serve locally
   docsify serve .
   # Visit http://localhost:3000
   ```

4. **Commit changes:**

   ```bash
   git add .
   git commit -m "Your detailed commit message"
   ```

   Note: Pre-commit hooks will auto-format your changes

5. **Push to trigger CI:**

   ```bash
   git push origin master
   ```

6. **Review CI results:**

   - Check GitHub Actions for lint workflow status
   - If auto-fixes are needed, a PR will be created automatically
   - Merge the auto-fix PR if appropriate

### Adding New Documentation

1. **Create new Markdown file** in appropriate directory
2. **Follow naming convention:** `HowTo-Topic-Name.md`
3. **Add to sidebar navigation** in `_sidebar.md`
4. **Include frontmatter if needed** (though Docsify doesn't require YAML
   frontmatter)
5. **Test links** - all internal links should be relative paths
6. **Commit with descriptive message**

### Updating Configuration

**Docsify configuration** (`index.html`):

- Theme settings
- Search configuration
- Navigation settings
- External link behavior

**Linter configuration:**

- `.mega-linter.yml` - MegaLinter settings
- `.pre-commit-config.yaml` - Pre-commit hooks
- `.markdownlint.json` - Markdown linting rules
- `.prettierrc.yaml` - Prettier formatting rules
- `cspell.yaml` - Spell check configuration

## Testing Changes

### Local Testing Checklist

- [ ] Markdown files render correctly in Docsify
- [ ] All internal links work
- [ ] Code blocks have proper syntax highlighting
- [ ] Navigation (sidebar and navbar) updated if needed
- [ ] Spell check passes (or new words added to dictionary)
- [ ] No trailing whitespace or wrong line endings
- [ ] Pre-commit hooks pass

### CI Testing

After pushing, verify:

- [ ] Pre-commit workflow passes
- [ ] MegaLinter checks pass
- [ ] GitHub Pages deployment succeeds (for master branch)
- [ ] Live site renders correctly: <https://fchastanet.github.io/my-documents/>

## Troubleshooting

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
echo "newword" >> .cspell/bash.txt

# Sort the dictionary (pre-commit will do this)
pre-commit run file-contents-sorter

# Commit the updated dictionary
git add .cspell/bash.txt
git commit -m "Add 'newword' to spell check dictionary"
```

### GitHub Pages Not Updating

**Symptom:** Changes pushed but site not updating

**Solution:**

1. Check `docsify-gh-pages` workflow status in Actions
2. Verify changes were pushed to `master` branch
3. Clear browser cache and retry
4. Check GitHub Pages settings in repository settings

### Auto-fix PR Created Unexpectedly

**Symptom:** CI creates auto-fix PR for your changes

**Solution:**

1. Review the auto-fix PR changes
2. If acceptable, merge the PR
3. Pull the changes locally: `git pull origin master`
4. To skip auto-fixes in future, include "skip fix" in commit message

## Common Patterns

### Adding a New HowTo Guide

1. Create file: `HowTo/HowTo-New-Topic.md`

2. Add header and table of contents

3. Write content following Markdown standards

4. Update `_sidebar.md`:

   ```markdown
   - [New Topic](/HowTo/HowTo-New-Topic.md)
   ```

5. Add any new technical terms to `.cspell/bash.txt`

6. Commit and push

### Adding Code Examples

Use proper code fencing with language specification:

````markdown
```bash
#!/bin/bash
set -euo pipefail

echo "Hello, World!"
```
````

### Adding Images

1. Place image in `/images/` directory

2. Reference in Markdown:

   ```markdown
   ![Alt text](images/diagram.png)
   ```

3. Ensure image is optimized (not too large)

### Creating Cross-References

Use relative links for internal references:

```markdown
See also: [Docker Best Practices](/HowTo/HowTo-Write-Dockerfile.md)
```

## Configuration Files Reference

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

## Tools and Dependencies

### Required Tools (for local development)

- Git
- Python 3.9+ (for pre-commit)
- Node.js (optional, for local Docsify preview)

### Optional Tools

- `docsify-cli` - Local development server
- `pre-commit` - Git hook framework
- Docker (for MegaLinter local runs)

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

- [Docsify Documentation](https://docsify.js.org/)
- [MegaLinter Documentation](https://megalinter.io/)
- [Pre-commit Documentation](https://pre-commit.com/)
- [Markdown Guide](https://www.markdownguide.org/)

## Summary for Coding Agents

When working on this repository:

1. **Branch:** Always use `master`
2. **Commit messages:** Detailed Markdown format with title and changes list
3. **Linting:** Pre-commit hooks auto-fix most issues
4. **Line length:** 80-character wrapping for Markdown
5. **Spell checking:** Add technical terms to `.cspell/bash.txt`
6. **Navigation:** Update `_sidebar.md` when adding new pages
7. **Testing:** Verify links and rendering locally or via GitHub Pages
8. **CI/CD:** Workflows handle linting and deployment automatically
9. **On chat:** Only provide relevant changes, not entire files
