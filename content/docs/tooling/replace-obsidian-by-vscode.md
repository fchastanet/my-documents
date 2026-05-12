---
title: Replace Obsidan by VSCode
pageInfo: |
  In this guide, we will explore how to replace Obsidian with Visual Studio Code (VSCode) for note-taking and knowledge

  management.

  Obsidian offers a powerful markdown-based note-taking experience, but as a developer, you might find VSCode more

  versatile and integrated with your workflow. With the right extensions and configurations, you can achieve a similar

  experience to Obsidian while benefiting from the features of VSCode.
description: 'Replace Obsidian with VSCode: replicate Markdown note-taking, linking, backlinks, graph view and frontmatter using extensions.'
categories:
  - Documentation
tags:
  - documentation
  - markdown
  - productivity
  - tooling
  - vscode
draft: true
date: '2026-05-12T23:28:40+02:00'
lastmod: '2026-05-12T20:22:46.379000Z'
version: '1.0'
---

# Replace Obsidan by VSCode

## 1. Obsidian features to replicate in VSCode

### 1.1. Markdown support

VSCode has built-in support for Markdown, allowing you to create and edit Markdown files with ease. You can also install
extensions like "Markdown All in One" to enhance your Markdown editing experience.

### 1.2. Graph view

While VSCode does not have a native graph view like Obsidian, you can use extensions like "Markdown Preview Enhanced" to
visualize your notes in a more structured way. Additionally, you can use the "Markdown Links" extension to manage and
navigate between your notes.

### 1.3. Note linking

Obsidian's note linking feature allows you to create connections between your notes using double brackets
`[[note name]]`. In VSCode, you can achieve similar functionality using the
[Markdown Memo plugin](https://marketplace.visualstudio.com/items?itemName=svsool.markdown-memo).

### 1.4. Backlinks

VSCode does not have a built-in backlink feature, but you can use the "Markdown Links" extension to create and manage
links between your notes. This extension allows you to easily navigate between related notes, similar to Obsidian's
backlink functionality.

### 1.5. Frontmatter

VSCode supports frontmatter in Markdown files, allowing you to add metadata to your notes. But you cannot hide them like
in Obsidian, so you can use the "Markdown Front Matter" extension to manage and edit your frontmatter more efficiently.

### 1.6. Cross reference and linking

Obsidian maintains a powerful linking system that allows you to create connections between your notes. In VSCode, you
can achieve similar functionality using the "Markdown Links" extension, which allows you to create and manage links
between your notes but it could result is missing or moved links not being updated automatically.

It could be leveraged with a bash script to check for broken links and update them accordingly, but it requires
additional setup and maintenance.

### 1.7. Bases core plugin

The "Bases core plugin" is a powerful tool for managing and organizing your notes in Obsidian. As previous point, it
supposes to maintain a database of your notes and their relationships, which allows for features like backlinks and
graph view.

## 2. Conclusion
