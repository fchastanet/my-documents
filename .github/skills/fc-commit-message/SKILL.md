---
name: "fc-commit-message"
description: "Use when: writing commit messages, reviewing changes before committing, or planning changesets. Enforces message format, code quality checks, and documentation standards for commits."
---

# Commit Message & Changeset Guidelines

## Required Format Structure

### Title (First Line)

- **Length**: 120 characters maximum
- **Unique**: only the first line can be a title
- **Imperative Mood**: "add" not "adds" or "added", present tense
- **Format**: `[emoji][scope]: description`
  - Example: `[✨feat][auth]: Add WebSocket integration`
- **Capitalization**: First letter capitalized
- **Blank line**: Always add a blank line after the title

### Summary Paragraph

- **DO NOT include if**
  - The commit is straightforward and self-explanatory from the title
  - The changes are minor and do not require additional context
- **Length**: 100-200 characters (1-2 sentences)
- **Focus**: What changed and why (not how)
- **Tense**: Present tense
- **Blank line**: Always add a blank line after the summary

### Detailed Description (for commits with multiple changes)

- **DO NOT include if**
  - Summary paragraph is not needed
  - The commit only affects a single area or is straightforward
  - The changes are self-explanatory from the title and summary
  - The commit is a simple fix or minor enhancement that does not require additional context
  - The changes are limited to a small number of files and do not impact multiple components or layers of the application
  - The commit does not introduce any new patterns, migrations, or complex logic that would benefit from additional explanation
- **If included**:
  - **Organization**: Use section headers with relevant emojis
  - **Sub-items**: Use bullet points under each section
  - **Grouping**: Group related changes together
  - **References**: Include file names, layers, or components when relevant
  - **Line length**: Limit body lines to 120 characters
  - **Special sections** (all optional, include as needed, always in this order):
    - `## ✨ New Features`: New features
    - `## 💥 Breaking Changes`: Document any backward-incompatible changes
    - `## 🛡️ Security`: Highlight security-related changes
    - `## 📊 Performance`: Detail performance optimizations
    - `## 🧪 Tests`: Describe new or updated tests
    - `## 📄 Documentation`: Note documentation updates
  - Explain **what** and **why**, not how
  - Blank line before footer

### Emoji Guide

Use these standard emojis to categorize change types:

| Emoji          | Meaning            | Use Case                                  |
|----------------|--------------------|-------------------------------------------|
| `[🔧refactor]` | Refactoring        | Code refactoring without behavior change  |
| `[🖥️ui]`       | UI                 | User interface changes                    |
| `[🛠️infra]`    | Infrastructure     | Build tools, CI/CD, workflows             |
| `[🛡️security]` | Security           | Security improvements or fixes            |
| `[📊perf]`     | Performance        | Performance optimizations                 |
| `[📚docs]`     | Documentation      | Documentation updates                     |
| `[🚀ci]`       | Deployment         | Release or deployment-related changes     |
| `[💥breaking]` | Breaking Change    | Breaking changes                          |
| `[🧪test]`     | Tests              | Adding or updating tests                  |
| `[🖋️style]`    | Formatting         | Code formatting changes (no logic change) |
| `[📦chore]`    | Dependencies       | Adding or updating dependencies           |
| `[⚙️config]`   | Configuration      | Changes to configuration files            |
| `[🐛fix]`      | Bug Fix            | Fixes to existing bugs                    |
| `[✨feat]`     | Feature            | New functionality or features             |

### Scope (optional)

Specify the affected component: `[auth]`, `[api]`, `[database]`, `[ui]`, etc.

### Things to Avoid

- ❌ Never use "WIP", "temp", or placeholder text
- ❌ Never include redundant or duplicate information
- ❌ Never omit the scope from the title
- ❌ Never use imperative beyond the first sentence in the summary
- ❌ Never exceed line length guidelines without good reason (and then explain why)

### Footer (optional)

- Reference issues: `Fixes #123` or `Closes #456`
- Note breaking changes: `BREAKING CHANGE: description`

## Examples

Simple fix (Level 1):

```text
[✨feat][api]: handle null response in user lookup
```

More complex changes:

- (Level 2) Use [Feature with context](references/feature-with-context-commit-msg.txt) when changes apply to only one area but require additional context to understand the impact.
- (Level 2) Use [Breaking change](references/breaking-change-commit-msg.txt) when introducing backward-incompatible changes.
- (Level 3) Use [Detailed Example](references/detailed-commit-msg.txt) when changes span multiple areas or require detailed explanation. This format includes section headers, bullet points, and references to related documentation or issues.

## When Generating Commit Messages

1. **Analyze the changes** using git diff or the changes tool
2. **Determine scope**: Single file, component, or multiple areas?
3. **Pick appropriate detail level** (minimal, standard, or comprehensive)
4. **Select emoji** that best represents the primary change
5. **Define scope** (the area/component affected)
6. **Write imperative title** that completes: "This commit will..."
7. **Add summary** explaining the why
8. **Add details** only if changes span multiple areas or are complex
9. **Remove footer** with co-authored-by
10. **Output in code block** using quadruple backticks

## Tips for Better Commit Messages

- **Be specific**: "Fix null reference in user service" is better than "Bug fix"
- **Explain context**: Why were these changes needed? What problem do they solve?
- **Use present tense**: "Add feature" not "Added feature"
- **Keep it scannable**: Use headers and bullet points for readability
- **Reference issues**: Use #123 format to link to related issues
- **Link to docs**: Reference design docs or specifications when relevant
