# Quick Reference: Hugo Site Development

**Repository:** my-documents  
**Theme:** Docsy  
**Hugo Version:** 0.110+

## Local Development

### Start

```bash
# Download dependencies (first time only)
hugo mod get -u

# Start development server
hugo server -D

# Open browser
# http://localhost:1313/my-documents/
```

### Auto-reload
- Edit markdown files
- Browser auto-refreshes
- Press `Ctrl+C` to stop

## Adding Content

### New Page in Existing Section

```bash
hugo new docs/bash-scripts/my-page.md
```

Edit the file with frontmatter:
```yaml
---
title: My New Page
description: Brief description for SEO
weight: 10
categories: [Bash]
tags: [bash, example]
---

Your content here...
```

### New Section

Create directory in `content/en/docs/` and `_index.md`:
```bash
mkdir -p content/en/docs/new-section
touch content/en/docs/new-section/_index.md
```

### Frontmatter Fields

```yaml
---
title: Page Title              # Required, shown as H1
description: SEO description   # Required, used in meta tags
weight: 10                      # Optional, controls ordering (lower = earlier)
categories: [category-name]    # Optional, for content organization
tags: [tag1, tag2]             # Optional, for tagging
---
```

## Content Organization

```
content/en/docs/
├── bash-scripts/          # Weight: 10 (first)
├── howtos/               # Weight: 20
│   └── howto-write-jenkinsfile/  # Subsection
├── lists/                # Weight: 30
└── other-projects/       # Weight: 40 (last)
```

**Navigation:** Automatic based on directory structure + `weight` frontmatter

## Images and Assets

Place in `static/` directory:

```
static/
├── howto-write-dockerfile/    # For Dockerfile guide images
├── howto-write-jenkinsfile/   # For Jenkins guide images
└── your-section/              # Create as needed
```

Reference in markdown:
```markdown
![Alt text](/howto-write-dockerfile/image-name.png)
```

## Common Docsy Shortcodes

### Info Box
```markdown
{{% pageinfo color="primary" %}}
This is an informational box.
{{% /pageinfo %}}
```

### Alert
```markdown
{{% alert title="Warning" color="warning" %}}
This is a warning message.
{{% /alert %}}
```

### Tabbed Content
```markdown
{{% tabpane %}}
{{% tab header="Tab 1" %}}
Content for tab 1
{{% /tab %}}
{{% tab header="Tab 2" %}}
Content for tab 2
{{% /tab %}}
{{% /tabpane %}}
```

See full list: https://www.docsy.dev/docs/reference/shortcodes/

## Code Blocks

Specify language for syntax highlighting:

````markdown
```bash
#!/bin/bash
echo "Hello World"
```

```yaml
key: value
nested:
  item: value
```

```python
def hello():
    print("Hello World")
```
````

## Internal Links

Use relative paths:
```markdown
[Link text](/docs/bash-scripts/page-name/)
[Link text](/docs/section/_index/)
```

Hugo resolves these automatically.

## Building for Production

```bash
# Build minified site
hugo --minify

# Output goes to public/ directory
# GitHub Actions handles deployment automatically
```

## Content Guidelines

- **Line length:** 120 characters max (enforced by mdformat)
- **Headers:** Use ATX style (#, ##, ###)
- **Lists:** 2-space indentation
- **Code blocks:** Always specify language
- **Images:** Include alt text
- **Links:** Use relative paths for internal, full URLs for external

## Spell Checking

Add technical terms to `.cspell/bash.txt`:
```bash
echo "newword" >> .cspell/bash.txt
pre-commit run file-contents-sorter    # auto-sorts
```

## Git Workflow

1. **Branch:** Always use `master`
2. **Commit:** Detailed message with changes
3. **Push:** Triggers linting and Hugo build
4. **CI/CD:** GitHub Actions handles rest

```bash
git add .
git commit -m "Add new documentation on topic"
git push origin master
```

## Troubleshooting

### Hugo server won't start
```bash
rm go.sum
hugo mod clean
hugo mod get -u
hugo server -D
```

### Module not found errors
```bash
hugo version  # Check it says "extended"
hugo mod get -u
```

### Build artifacts in way
```bash
rm -rf resources/ public/
hugo --minify
```

### Link errors
- Check relative path is correct
- Verify file exists in expected location
- Internal links should start with `/docs/`

## File Locations

| Item | Path |
| ---- | ---- |
| Site config | `hugo.yaml` |
| Home page | `content/en/_index.html` |
| Docs home | `content/en/docs/_index.md` |
| Bash guides | `content/en/docs/bash-scripts/` |
| How-TO guides | `content/en/docs/howtos/` |
| Lists | `content/en/docs/lists/` |
| Images | `static/section-name/` |
| Archetypes | `archetypes/*.md` |
| Theme config | `hugo.yaml` params section |

## SEO Best Practices

- ✅ Use descriptive titles and descriptions
- ✅ Add `weight` to control ordering
- ✅ Use categories and tags
- ✅ Include proper alt text on images
- ✅ Link to related content
- ✅ Use clear heading hierarchy
- ✅ Keep page descriptions under 160 chars

## Submitting to Search Engines

1. Build site: `hugo --minify` (GitHub Actions does this)
2. GitHub Actions deploys to GitHub Pages
3. Submit sitemap to search console:
   - https://search.google.com/search-console
   - Add property
   - Submit `/sitemap.xml`

## Useful Commands

```bash
hugo server -D                          # Run dev server
hugo --minify                           # Build for production
hugo --printI18nWarnings                # Check for i18n issues
hugo --printPathWarnings                # Check path warnings
hugo --printUnusedTemplates             # Check unused templates
pre-commit run -a                       # Run all linters
```

## Theme Customization

To override Docsy styles:
1. Create `/assets/scss/_custom.scss`
2. Add custom CSS
3. Rebuild with `hugo server`

For more details: https://www.docsy.dev/docs/

---

**Quick Links:**
- [Hugo Docs](https://gohugo.io/documentation/)
- [Docsy Theme](https://www.docsy.dev/)
- [GitHub Repo](https://github.com/fchastanet/my-documents)
- [Published Site](https://fchastanet.github.io/my-documents/)
