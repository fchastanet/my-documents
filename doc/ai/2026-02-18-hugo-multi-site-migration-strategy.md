# Improved Prompt: Hugo Multi-Site Migration Strategy Analysis

**Date:** 2026-02-18
**Original Request:** Evaluate centralized multi-site build vs reusable workflows
**Context:** Migrating 4 Docsify documentation sites to Hugo with shared infrastructure

## Original Prompt Summary

User asked to:

1. Evaluate a new centralized build solution (my-documents orchestrates all site builds)
2. Compare with previously proposed reusable workflows approach
3. Detail migration steps for my-documents and bash-compiler
4. Address specific requirements:
   - my-documents owns generation of all sub-sites
   - GitHub workflow checks out master of each dependent repo (not git submodules)
   - Hugo.yaml common to all sub-sites with per-site customization (colors, etc.)
   - Build all sites at once
   - Deploy separately to each repo's GitHub Pages vs all to my-documents
   - Per-site configuration for colors, branding, menus
5. Identify any overlooked considerations
6. Propose better alternatives if any
7. Update HUGO-MIGRATION-REFERENCE.md with analysis

## Key Clarifications Obtained

Through interactive questions, established:

1. **Deployment preference:** Separate GitHub Pages (preferred), but OK with centralized if simpler
2. **Trigger mechanism:** Repository dispatch (immediate rebuild on dependent repo changes)
3. **Build scope:** Rebuild all sites on any change (simpler than selective)
4. **Customization scope:** Full customization (colors, logos, menus, footer, SEO, links)

## Improved Comprehensive Prompt

```
Goal: Design and document a multi-repository Hugo static site migration strategy

Context:
- Current: 4 repositories using Docsify (client-side rendered docs)
- Target: Hugo with Docsy theme (SEO-optimized static sites)
- Repositories: fchastanet/my-documents, bash-compiler, bash-tools, bash-tools-framework
- All under same GitHub organization (fchastanet)
- All serve related purpose (Bash tooling documentation)

Requirements:
1. Migrate from Docsify to Hugo + Docsy theme
2. Share theme customizations and infrastructure
3. Maintain individual GitHub Pages URLs per repository
4. Minimize maintenance burden across 4 repositories
5. Ensure consistency while allowing per-site customization

Evaluation Criteria:
1. Compare two architectural approaches:
   a) Centralized orchestrator (my-documents builds all sites)
   b) Decentralized with reusable workflows (each repo builds independently)

2. For centralized approach, address:
   - How to check out multiple repos without git submodules
   - How to share Hugo configuration with per-site overrides
   - How to build multiple sites in one workflow
   - How to deploy to separate GitHub Pages from centralized build
   - How dependent repos trigger the centralized build

3. Per-site customization needs:
   - Primary/secondary colors
   - Logo and branding
   - Menu structure
   - Footer content
   - SEO metadata (title, description, keywords)
   - GitHub/social links

4. Consider:
   - Build time and performance
   - Maintenance burden
   - Complexity of setup
   - Failure isolation
   - Secret management (deploy keys, PATs)
   - Local development workflow
   - CI/CD complexity

Deliverables:
1. Clear comparison matrix of both approaches
2. Recommendation with justification
3. Complete implementation guide for chosen approach:
   - All required files with full content
   - Step-by-step setup instructions
   - Secret generation procedures
   - Troubleshooting guide
4. Migration checklist for pilot repository (bash-compiler)
5. Simplified quick-reference document
6. Address any overlooked edge cases

Constraints:
- Must maintain separate GitHub Pages URLs (not a true monorepo)
- Prefer simplicity over perfection
- Document must be actionable (copy-paste ready configs)
- Should work with GitHub Actions (no external CI)

Expected Analysis Depth:
- Evaluate security implications (deploy keys vs PATs)
- Consider build time optimization (parallel builds, caching)
- Address local development preview workflow
- Identify potential failure modes and mitigations
- Compare long-term maintenance scenarios

Output Format:
- Clear executive summary with recommendation
- Side-by-side comparison table
- Complete working code examples (not pseudo-code)
- Visual architecture diagrams (ASCII art)
- FAQ section addressing common questions
- Actionable next steps checklist
```

## Improvements Over Original

**Original prompt issues:**

1. Too open-ended ("evaluate this solution")
2. Missing decision criteria
3. Unclear customization scope
4. Didn't specify output format detail level
5. No mention of edge cases to consider

**Improved prompt strengths:**

1. ✅ Explicit evaluation criteria
2. ✅ Clear comparison dimensions
3. ✅ Specific deliverables list
4. ✅ Constraints and context upfront
5. ✅ Requests working code (not pseudo-code)
6. ✅ Asks for security and failure

 mode analysis
7. ✅ Specifies output format (tables, diagrams, checklists)
8. ✅ Emphasizes actionable, copy-paste ready content

## Key Learnings

**What worked:**

- Interactive questions revealed preference: separate GitHub Pages (simplicity trade-off OK)
- Clarifying customization scope prevented assumptions
- Asking about build scope simplified design (all sites vs selective)

**What could improve:**

- Could have asked about team size/familiarity with Hugo
- Could have asked about expected content update frequency
- Could have discussed security comfort level (SSH keys vs PATs)

## Recommended Prompt Template for Similar Tasks

```
# Architecture Decision for [SYSTEM_NAME]

## Context
- Current state: [describe existing setup]
- Desired state: [describe target setup]
- Constraints: [list technical/organizational constraints]
- Stakeholders: [who uses this, who maintains it]

## Requirements
[Numbered list of must-haves]

## Alternative Approaches to Evaluate
1. [Approach A] - [one-line description]
2. [Approach B] - [one-line description]
[List 2-4 alternatives]

## Evaluation Criteria
[Table with criteria × approaches, or list of dimensions]
- Complexity
- Maintenance burden
- Performance
- Security
- [domain-specific criteria]

## Specific Questions to Address
1. [Technical question 1]
2. [Trade-off question 2]
3. [Edge case question 3]

## Deliverables
- Comparison matrix
- Recommendation with justification
- Complete implementation guide with:
  - All files (full content, not templates)
  - Step-by-step setup
  - Troubleshooting
  - Testing/validation steps
- Quick reference guide
- Migration checklist

## Expected Analysis Depth
- Consider [specific aspect 1]
- Address [specific aspect 2]
- Identify [failure modes / edge cases / security implications]

## Output Format
- Executive summary (2-3 paragraphs)
- Comparison table
- Architecture diagrams (ASCII or mermaid)
- Working code examples (copy-paste ready)
- FAQ section
- Actionable next steps
```

## Reusability

This prompt structure can be adapted for:

- CI/CD pipeline design decisions
- Multi-tenant architecture choices
- Shared library strategies
- Deployment strategy comparisons
- Infrastructure as Code approaches

**Key components to always include:**

1. Clear context (current → desired state)
2. Explicit evaluation criteria
3. Specific deliverables list
4. Constraint documentation
5. Request for working examples (not pseudo-code)
6. Edge case consideration requirement

---

**Meta-Learning:** Breaking down architectural decisions into:

- Approaches to compare
- Criteria for comparison
- Desired output format
- Level of detail needed

...leads to much more actionable AI responses than "evaluate [thing]" prompts.
