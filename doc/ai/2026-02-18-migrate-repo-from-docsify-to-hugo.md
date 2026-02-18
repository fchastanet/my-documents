# Copilot Prompt: Migrate Repository from Docsify to Hugo/Docsy

**Date:** 2026-02-18
**Purpose:** Migrate a documentation repository from Docsify to Hugo with Docsy theme, integrated with the centralized my-documents orchestrator

---

## Context

You are migrating a documentation repository (e.g., `bash-compiler`, `bash-tools`, `bash-tools-framework`, or `bash-dev-env`) from **Docsify** to **Hugo with Docsy theme**.

The repository will be **part of a centralized build orchestrator** hosted in the `fchastanet/my-documents` repository, which builds and deploys all documentation sites together.

## Migration Objectives

1. **Convert Docsify content to Hugo/Docsy format**
   - Migrate Markdown files from Docsify structure to Hugo content structure
   - Convert Docsify-specific syntax to Hugo shortcodes where applicable
   - Preserve existing documentation content and organization

2. **Integrate with centralized orchestrator**
   - Add trigger workflow to notify my-documents when content changes
   - Ensure content structure matches orchestrator expectations
   - No Hugo configuration needed in this repo (handled by orchestrator)

3. **Maintain repository cleanliness**
   - Keep only essential files (content, static assets, trigger workflow)
   - Remove Docsify-specific files (index.html, _sidebar.md, .nojekyll, etc.)
   - Preserve non-docs files (README, LICENSE, source code, etc.)

4. **Test the migration**
   - Verify content renders correctly in Hugo
   - Test trigger workflow
   - Validate links and images
   - Check SEO metadata

## Prerequisites

Before starting, ensure:

- [ ] You have access to the repository to migrate
- [ ] The repository name is one of: `bash-compiler`, `bash-tools`, `bash-tools-framework`, `bash-dev-env`
- [ ] You have admin access to create secrets and deploy keys
- [ ] The `fchastanet/my-documents` orchestrator is already set up with configuration for this site

## Migration Steps

### Step 1: Analyze Current Docsify Structure

1. **Identify Docsify files:**

   ```bash
   # Common Docsify files to identify:
   - index.html (Docsify entry point)
   - _sidebar.md (navigation)
   - _navbar.md (top navigation)
   - .nojekyll (GitHub Pages config)
   - docs/ or similar content directory
   ```

2. **Document current content organization:**
   - List all documentation directories
   - Note any custom Docsify plugins or configurations
   - Identify embedded HTML or Docsify-specific syntax

### Step 2: Create Hugo Content Structure

1. **Create content directory:**

   ```bash
   mkdir -p content/en/docs
   ```

2. **Create site homepage:**

   ```bash
   # Create content/en/_index.md
   ```

   Example frontmatter:

   ```markdown
   ---
   title: [Site Title]
   description: [Brief description of the project]
   ---

   [Welcome content]

   ## Features

   - Feature 1
   - Feature 2

   ## Quick Start

   [Getting started guide]
   ```

3. **Create docs landing page:**

   ```bash
   # Create content/en/docs/_index.md
   ```

   Example:

   ```markdown
   ---
   title: Documentation
   description: Complete documentation for [Project Name]
   weight: 1
   ---

   Welcome to the documentation!
   ```

### Step 3: Migrate Content

1. **Convert Docsify content to Hugo structure:**
   - Move markdown files from docs/ to content/en/docs/
   - Organize into logical subdirectories (e.g., getting-started/, guides/, reference/)
   - Add frontmatter to each page

2. **Add frontmatter to all pages:**

   ```yaml
   ---
   title: Page Title
   description: Brief description for SEO
   weight: 10  # Controls ordering (lower = higher in menu)
   categories: [documentation]  # Optional
   tags: [bash, scripts]  # Optional
   ---
   ```

3. **Update internal links:**
   - Change Docsify links from `[text](page.md)` to Hugo format `[text](/docs/section/page/)`
   - Use relative paths without .md extension
   - Verify all internal links

4. **Migrate static assets:**

   ```bash
   mkdir -p static/images
   # Move images from docs/images to static/images
   # Update image references in markdown files
   ```

### Step 4: Add Trigger Workflow

1. **Create workflow file:**

   ```bash
   mkdir -p .github/workflows
   ```

2. **Copy trigger workflow:**

   ```bash
   # Copy from fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml
   # Save as .github/workflows/trigger-docs.yml
   ```

3. **Verify workflow paths:**
   - Ensure `paths` in workflow includes content/ and static/

### Step 5: Clean Up Docsify Files

1. **Remove Docsify-specific files:**

   ```bash
   # Files to remove:
   rm index.html
   rm .nojekyll
   rm -rf docs/_sidebar.md docs/_navbar.md
   # Remove any Docsify plugins or configurations
   ```

2. **Update .gitignore:**

   ```
   # Hugo build artifacts
   public/
   resources/_gen/
   .hugo_build.lock
   hugo.yaml.tmp
   ```

### Step 6: Setup GitHub Secrets

1. **In fchastanet/my-documents repository:**
   - Go to Settings → Secrets and variables → Actions
   - Verify secret exists: `DEPLOY_KEY_[REPO_NAME]` (e.g., `DEPLOY_KEY_BASH_COMPILER`)
   - Secret should contain the private SSH deploy key

2. **In this repository (the one being migrated):**
   - Go to Settings → Secrets and variables → Actions
   - Add new secret: `DOCS_BUILD_TOKEN`
   - Value: Personal Access Token with `repo` scope

**How to create PAT:**

```
1. GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token (classic)
3. Name: "Documentation Build Trigger"
4. Scopes: Select "repo" (all repo permissions)
5. Copy token and add as secret
```

### Step 7: Test Migration Locally

1. **Clone my-documents repo and this repo side-by-side:**

   ```bash
   cd /path/to/workspace
   git clone https://github.com/fchastanet/my-documents.git
   cd my-documents

   # Link this repo for testing
   mkdir -p sites
   ln -s ../../[this-repo-name] sites/[this-repo-name]
   ```

2. **Build this site locally:**

   ```bash
   cd my-documents
   make install-yq
   make build-site SITE=[this-repo-name]
   ```

3. **Verify output:**

   ```bash
   # Check build output
   ls -la build/[this-repo-name]/public/

   # Test with local server
   cd build/[this-repo-name]
   hugo server -D --port 1314
   # Visit http://localhost:1314/[this-repo-name]/
   ```

4. **Automated testing:**

   ```bash
   # Run full test suite
   cd my-documents
   make test-all
   ```

### Step 8: Verify Content Quality

**Checklist:**

- [ ] All pages have proper frontmatter (title, description, weight)
- [ ] Navigation works correctly (hierarchical structure)
- [ ] Internal links resolve without 404s
- [ ] Images display correctly
- [ ] Code blocks have language specification
- [ ] No Docsify-specific syntax remains
- [ ] SEO meta tags are present
- [ ] Mobile responsive layout works

**Test commands:**

```bash
# Check for broken links
grep -r "](.*\.md)" content/  # Should find none

# Check for missing frontmatter
find content -name "*.md" -exec sh -c 'head -5 "$1" | grep -q "^---$" || echo "Missing frontmatter: $1"' _ {} \;

# Check for Docsify syntax
grep -r "docsify" content/

# Verify image paths
find content -name "*.md" -exec grep -H "!\[.*\](.*)" {} \;
```

### Step 9: Commit and Push

1. **Stage changes:**

   ```bash
   git add content/ static/ .github/workflows/trigger-docs.yml .gitignore
   git add -u  # Stage deletions (Docsify files)
   ```

2. **Commit with descriptive message:**

   ```markdown
   feat: migrate documentation from Docsify to Hugo/Docsy

   ## Changes

   - Migrated all documentation content to Hugo structure
   - Added trigger workflow for centralized build orchestrator
   - Removed Docsify-specific files (index.html, .nojekyll, etc.)
   - Organized content into logical sections
   - Added frontmatter to all pages
   - Updated internal links to Hugo format
   - Migrated static assets to static/

   ## Testing

   - [x] Local build successful
   - [x] All pages render correctly
   - [x] Internal links verified
   - [x] Images display properly
   - [x] SEO metadata present

   Integrated with fchastanet/my-documents centralized orchestrator.
   Documentation will be deployed to: https://fchastanet.github.io/[repo-name]/
   ```

3. **Push to master:**

   ```bash
   git push origin master
   ```

### Step 10: Verify Deployment

1. **Check trigger workflow:**
   - Go to Actions tab in this repository
   - Verify "Trigger Documentation Build" workflow ran successfully

2. **Check orchestrator build:**
   - Go to <https://github.com/fchastanet/my-documents/actions>
   - Verify "Build All Documentation Sites" workflow is running
   - Check build logs for this site

3. **Verify deployment:**
   - Wait 2-5 minutes for deployment
   - Visit <https://fchastanet.github.io/[repo-name]/>
   - Navigate through documentation
   - Test search functionality
   - Verify links and images

4. **Check SEO:**

   ```bash
   # View page source and verify:
   - <meta name="description" content="...">
   - <meta name="keywords" content="...">
   - <script type="application/ld+json"> (structured data)
   - <meta property="og:*"> (Open Graph)
   ```

## Troubleshooting

### Build Fails in Orchestrator

**Symptom:** Build fails with "content not found" or similar

**Solutions:**

1. Verify content directory structure matches Hugo expectations
2. Check that content/en/ directory exists
3. Ensure all markdown files are in content/ subdirectories

### Links Not Working

**Symptom:** 404 errors on internal links

**Solutions:**

1. Use Hugo link format: `/docs/section/page/` (no .md extension)
2. Use relative links: `../other-page/`
3. Verify frontmatter has correct title

### Images Not Displaying

**Symptom:** Broken image links

**Solutions:**

1. Move images to static/ directory
2. Reference as `/images/file.png` (relative to static/)
3. Verify image file extensions are lowercase

### Trigger Workflow Not Running

**Symptom:** Push doesn't trigger my-documents build

**Solutions:**

1. Check DOCS_BUILD_TOKEN secret is set correctly
2. Verify PAT has repo scope
3. Check workflow paths include changed files
4. Manually trigger: Repository → Actions → Trigger Documentation Build → Run workflow

## Post-Migration Checklist

- [ ] All content migrated and renders correctly
- [ ] Trigger workflow runs successfully
- [ ] Site deployed to GitHub Pages
- [ ] All links and images work
- [ ] SEO metadata present and correct
- [ ] Search functionality works
- [ ] Mobile layout responsive
- [ ] Navigation menu logical and complete
- [ ] README.md updated with link to new docs site
- [ ] Old Docsify deployment disabled (if applicable)

## Repository File Structure (After Migration)

```
[repo-name]/
├── .github/
│   └── workflows/
│       └── trigger-docs.yml          ← Triggers my-documents build
├── content/
│   └── en/
│       ├── _index.md                 ← Homepage
│       └── docs/
│           ├── _index.md             ← Docs landing
│           ├── getting-started/
│           ├── guides/
│           └── reference/
├── static/
│   ├── images/                       ← Images and assets
│   └── downloads/                    ← Downloadable files
├── .gitignore                        ← Updated for Hugo
├── README.md                         ← Points to new docs site
└── [other repo files]                ← Unchanged
```

## Self-Testing Protocol

**Before completing migration, run this checklist:**

```bash
# 1. Verify local build
cd /path/to/my-documents
make build-site SITE=[repo-name]
echo "✅ Build completed without errors"

# 2. Start local server
cd build/[repo-name]
hugo server -D --port 1314 &
sleep 3

# 3. Test homepage
curl -s http://localhost:1314/[repo-name]/ | grep -q "<title>" && echo "✅ Homepage loads"

# 4. Test docs page
curl -s http://localhost:1314/[repo-name]/docs/ | grep -q "<title>" && echo "✅ Docs page loads"

# 5. Check for 404s (sample URLs)
for url in / /docs/ /docs/getting-started/; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:1314/[repo-name]$url")
  if [ "$code" = "200" ]; then
    echo "✅ $url returns 200"
  else
    echo "❌ $url returns $code"
  fi
done

# 6. Stop server
pkill hugo

# 7. Commit and push
cd /path/to/[repo-name]
git status
git add -A
git commit -m "feat: migrate to Hugo/Docsy"
git push origin master

# 8. Watch Actions
echo "🔍 Check GitHub Actions:"
echo "  - This repo: https://github.com/fchastanet/[repo-name]/actions"
echo "  - Orchestrator: https://github.com/fchastanet/my-documents/actions"

# 9. Verify deployment
echo "⏳ Wait 3-5 minutes, then check:"
echo "  https://fchastanet.github.io/[repo-name]/"
```

## Example Commit Messages

**Initial migration:**

```
feat: migrate documentation from Docsify to Hugo/Docsy

- Convert Docsify markdown to Hugo content structure
- Add frontmatter to all documentation pages
- Update internal links to Hugo format
- Migrate images to static/images/
- Add trigger workflow for centralized orchestrator
- Remove Docsify files (index.html, .nojekyll)

Tested locally with my-documents orchestrator.
```

**Follow-up fixes:**

```
fix: correct internal documentation links

- Update relative paths to absolute paths
- Remove .md extensions from links
- Fix image references in getting-started guide
```

---

## Notes for Copilot

- **Be thorough:** Check every markdown file for Docsify syntax
- **Preserve content:** Don't change the actual documentation content, only structure
- **Test extensively:** Use the self-testing protocol before declaring success
- **Auto-fix issues:** If you find broken links or missing frontmatter, fix them automatically
- **Report clearly:** Provide a summary of what was changed and what was tested

---

**This prompt should enable full autonomous migration with self-testing.**
