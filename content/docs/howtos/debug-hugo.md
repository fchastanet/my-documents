---
title: Debug Hugo
linkTitle: Debug Hugo
description: 'Debug Hugo: Quick guide to locate Hugo templates, use templateMetrics, override priorities, and fix common Docsy/Hugo template issues for faster debugging.'
type: docs
tags:
  - debugging
  - docsy
  - hugo
  - static-site-generator
  - templates
categories:
  - Bash
  - Documentation
  - testing
  - Tooling
  - web
previewImage: assets/debugHugo.webp
date: '2026-03-08T08:00:00+01:00'
lastmod: '2026-05-15T22:23:28+02:00'
version: '1.1'
---

<!--TOC-->

- [1. Finding Which Template is Being Used](#1-finding-which-template-is-being-used)
- [2. Hugo Template Lookup Order](#2-hugo-template-lookup-order)
- [3. Common Template Debugging Commands](#3-common-template-debugging-commands)
- [4. Template Override Priority](#4-template-override-priority)
- [5. Key Template Files for Comments/Customization](#5-key-template-files-for-commentscustomization)
- [6. Common Issues and Solutions](#6-common-issues-and-solutions)
- [7. Understanding Docsy's Template Structure](#7-understanding-docsys-template-structure)
- [8. Quick Debug Workflow](#8-quick-debug-workflow)

<!--TOC-->

## 1. Finding Which Template is Being Used

**Method 1: Template Metrics (Recommended)**

```bash
hugo server -D --templateMetrics --templateMetricsHints
```

This shows which templates are executed and execution times. Look for the page you're debugging in the output.

**Method 2: Add Debug Comments to Templates** Add this at the top of any template to verify it's being used:

```html
<!-- DEBUG: Using template layouts/docs/list.html -->
{{ warnf "TEMPLATE DEBUG: Rendering %s with %s" .RelPermalink .Layout }}
```

Then check the HTML source or terminal output.

**Method 3: Template Path in HTML (Temporary)** Add to your template for debugging:

```html
<!-- Template: {{ .Layout }} | Kind: {{ .Kind }} | Type: {{ .Type }} -->
{{ printf "
<!-- File: %s -->
" .File.Path }}
```

Remove after debugging to keep HTML clean.

## 2. Hugo Template Lookup Order

**For `_index.md` files (list pages):**

```text
content/docs/bash-scripts/_index.md  (with type: docs)
  ↓
  1. layouts/docs/list.html              ← Create this for docs sections with comments
  2. layouts/docs/section.html
  3. layouts/_default/list.html
  4. layouts/_default/section.html
  5. themes/docsy/layouts/docs/list.html
  6. themes/docsy/layouts/_default/list.html
```

**For regular `.md` files (single pages):**

```text
content/docs/bash-scripts/page.md  (with type: docs)
  ↓
  1. layouts/docs/single.html            ← Docsy uses baseof.html with blocks
  2. layouts/_default/single.html
  3. layouts/partials/_td-content.html   ← This is where content is rendered in Docsy
  4. themes/docsy/layouts/docs/baseof.html
```

**For blog posts:**

```text
content/blog/post.md
  ↓
  1. layouts/blog/single.html
  2. layouts/_default/single.html
  3. layouts/blog/_td-content.html       ← Override this for blog-specific changes
```

## 3. Common Template Debugging Commands

```bash
# Verify template exists in lookup path
find . -name "list.html" -o -name "single.html"

# Check if shared layouts are mounted correctly
hugo mod graph

# List all available templates (with jq installed)
hugo config --format json | jq '.module.mounts'

# Rebuild with verbose output
hugo server -D --logLevel debug --disableFastRender
```

## 4. Template Override Priority

1. **Local `layouts/` directory** (highest priority) - repo-specific overrides
2. **Mounted `shared/layouts/`** from my-documents via Hugo modules
3. **Docsy theme `themes/docsy/layouts/`** (lowest priority)

## 5. Key Template Files for Comments/Customization

| Template                                       | Purpose                      | Used For                      |
| ---------------------------------------------- | ---------------------------- | ----------------------------- |
| `shared/layouts/docs/list.html`                | Docs section index pages     | `_index.md` with `type: docs` |
| `shared/layouts/blog/_td-content.html`         | Blog post content wrapper    | Blog posts                    |
| `shared/layouts/_td-content.html`              | Regular page content wrapper | Regular docs pages            |
| `shared/layouts/partials/giscus-comments.html` | Giscus comment widget        | Included in above templates   |

## 6. Common Issues and Solutions

**Issue:** Comments not showing on `_index.md` pages\
**Solution:** Create `layouts/docs/list.html` (not `section.html` - wrong name!)

**Issue:** Changes to `shared/layouts/` not appearing\
**Solution:** Run `hugo mod clean && hugo mod get -u` to refresh modules

**Issue:** Template works locally but not in CI\
**Solution:** Check Hugo modules are committed in `go.mod` and `go.sum`

**Issue:** Wrong template being used\
**Solution:** Check frontmatter `type:` field - it controls template lookup path

**Issue:** Print out the full value of a variable in Hugo **Solution:**

- `{{ printf "%#v" $pages }}`
- `<pre>{{ debug.Dump .Params }}</pre>`
- Use the [`templates.Current`](https://gohugo.io/functions/templates/current/) function to visually mark template
  execution boundaries or to display the template call stack.

## 7. Understanding Docsy's Template Structure

Docsy uses a block-based template system:

- `baseof.html` defines the overall page structure
- `{{ block "main" }}` is where content goes
- `_td-content.html` partial is called by most layouts
- Override `_td-content.html` to customize content rendering globally

## 8. Quick Debug Workflow

1. **Identify the page type:** Regular page, section index, blog post?
2. **Check frontmatter:** Look for `type:` field (e.g., `type: docs`)
3. **Find template:** Use template lookup order above
4. **Verify template exists:** Check `shared/layouts/[type]/[kind].html`
5. **Add debug output:** Temporarily add `{{ warnf }}` to verify
6. **Test locally:** `hugo server -D --templateMetrics --disableFastRender`
7. **Remove debug code:** Clean up before committing
