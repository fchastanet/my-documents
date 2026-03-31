---
title: Use plantuml pre-commit hook to automatically generate diagrams
linkTitle: PlantUML pre-commit hook
description: Comprehensive documentation on how to use the PlantUML pre-commit hook to automatically generate diagrams, with a focus on speed and ease of use
categories: [Tooling]
tags: [PlantUML, pre-commit, tooling]
date: '2026-03-31T19:00:00+01:00'
lastmod: '2026-03-31T19:00:00+01:00'
version: '1.0'
---

## 1. Overview

The PlantUML pre-commit hook from [bash-tools-framework](https://github.com/fchastanet/bash-tools-framework)
automatically generates image files (SVG and PNG) from PlantUML (`.puml`) files whenever they are committed. This
ensures diagrams stay synchronized with their source files and eliminates manual export steps.

> [!TIP] Helpful advice for doing things better or more easily. All PlantUML diagrams in this repository are generated
> automatically using this hook. For examples of how to create reusable PlantUML components, see the
> [Reusable PlantUML Components guide](https://devlab.top/docs/howtos/how-to-write-plantuml/01-reusable-plantuml/).

## 2. Configuration

### 2.1. Basic Setup

Add the PlantUML hook to your `.pre-commit-config.yaml` file:

```yaml
repos:
  - repo: https://github.com/fchastanet/bash-tools-framework
    rev: master  # or a specific tag/commit (e.g., v6.2.10)
    hooks:
      - id: plantuml
```

This configuration will:

- Generate both **PNG** and **SVG** files by default
- Place generated images in the **same directory** as the source `.puml` file
- Only process changed `.puml` files (not all files on every commit)
- Run during the `pre-commit` stage

### 2.2. Hook Configuration Details

The PlantUML hook has the following characteristics:

| Property           | Value                                  | Description                            |
| ------------------ | -------------------------------------- | -------------------------------------- |
| **ID**             | `plantuml`                             | Hook identifier for configuration      |
| **Entry Point**    | `bin/plantuml`                         | Script that handles conversion         |
| **Default Args**   | `--ci --same-dir -f png -f svg`        | Generate PNG and SVG in same directory |
| **File Types**     | `file, non-executable, plantuml, text` | Targets `.puml` files                  |
| **Pass Filenames** | `true`                                 | Only processes changed files           |
| **Stages**         | `pre-commit, manual`                   | Runs automatically or on demand        |

### 2.3. Customizing Arguments

You can customize the hook behavior by overriding the default arguments:

#### 2.3.1. Output Format Options

```yaml
repos:
  - repo: https://github.com/fchastanet/bash-tools-framework
    rev: master
    hooks:
      - id: plantuml
        args: [--ci, --same-dir, -f, svg]  # Only generate SVG
```

```yaml
repos:
  - repo: https://github.com/fchastanet/bash-tools-framework
    rev: master
    hooks:
      - id: plantuml
        args: [--ci, --same-dir, -f, png]  # Only generate PNG
```

#### 2.3.2. Output Directory Options

```yaml
repos:
  - repo: https://github.com/fchastanet/bash-tools-framework
    rev: master
    hooks:
      - id: plantuml
        args: [--ci, -f, svg, -o, diagrams/]  # Output to specific directory
```

### 2.4. Available Arguments

| Argument     | Description                                                    |
| ------------ | -------------------------------------------------------------- |
| `--ci`       | CI mode - fail fast on errors without interactive prompts      |
| `--same-dir` | Generate images in the same directory as source `.puml` files  |
| `-f FORMAT`  | Output format: `png`, `svg`, `pdf`, etc. (can be repeated)     |
| `-o DIR`     | Output directory for generated images (overrides `--same-dir`) |

## 3. Usage Workflow

### 3.1. Automatic Generation on Commit

1. **Edit** your `.puml` file:

   ```bash
   vim content/docs/architecture/system-diagram.puml
   ```

2. **Stage** the file:

   ```bash
   git add content/docs/architecture/system-diagram.puml
   ```

3. **Commit** - the hook runs automatically:

   ```bash
   git commit -m "docs: update system diagram"
   ```

   The hook will:

   - Detect the changed `.puml` file
   - Generate `system-diagram.svg` and `system-diagram.png`
   - if a new file is generated or an existing file is updated, it will automatically stop the commit
   - Stage the modified files
   - Complete the commit with all files included

### 3.2. Manual Generation

Run the hook manually without committing:

```bash
pre-commit run plantuml --all-files                  # Process all .puml files
pre-commit run plantuml --files path/to/diagram.puml # Process specific file
```

### 3.3. Skipping the Hook

If you need to commit `.puml` files without regenerating images:

```bash
git commit --no-verify -m "WIP: diagram in progress"
```

## 4. Integration with PlantUML Best Practices

This hook works seamlessly with modular PlantUML architecture:

- **Reusable components** - hooks process included files correctly
- **Theme files** - changes to shared themes trigger regeneration
- **Master diagrams** - composite diagrams update when subsections change

For comprehensive examples of creating modular, reusable PlantUML diagrams, see:

- [Reusable PlantUML Components guide](https://devlab.top/docs/howtos/how-to-write-plantuml/01-reusable-plantuml/)

## 5. Advanced Configuration

### 5.1. Skip Specific Files

Use the `exclude` pattern to skip certain `.puml` files:

```yaml
repos:
  - repo: https://github.com/fchastanet/bash-tools-framework
    rev: master
    hooks:
      - id: plantuml
        # Skip files in scratch/ and drafts/
        exclude: ^scratch/|^drafts/
```

### 5.2. Multiple Output Configurations

If you need different formats for different directories:

```yaml
repos:
  - repo: https://github.com/fchastanet/bash-tools-framework
    rev: master
    hooks:
      - id: plantuml
        name: plantuml-docs
        files: ^content/docs/.*\.puml$
        args: [--ci, --same-dir, -f, svg]  # Docs use SVG only

      - id: plantuml
        name: plantuml-presentations
        files: ^presentations/.*\.puml$
        args: [--ci, --same-dir, -f, png]  # Presentations use PNG
```

## 6. Benefits

- **Automation**: No manual export steps required
- **Consistency**: All diagrams generated with same settings
- **Version Control**: Generated images automatically tracked with sources
- **Developer Experience**: Edit `.puml` files in any editor, images update on commit
- **CI/CD Ready**: Works in automated pipelines with `--ci` flag

## 7. See Also

- [Reusable PlantUML Components](https://devlab.top/docs/howtos/how-to-write-plantuml/01-reusable-plantuml/) - Learn to
  create modular diagrams
- [bash-tools-framework .pre-commit-hooks.yaml](https://github.com/fchastanet/bash-tools-framework/blob/master/.pre-commit-hooks.yaml)
  \- Full hook reference
