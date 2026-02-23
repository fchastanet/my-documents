---
title: My Documents - Trigger Reusable Workflow Documentation
description: Overview of the technical architecture and implementation details of the My Documents reusable workflow for triggering documentation builds
categories: [Documentation]
tags: [documentation, github-actions, reusable-workflow, github-app, authentication, secrets-management, ai-generated]
waigth: 11
creationDate: "2026-02-21"
lastUpdated: "2026-02-21"
version: "1.0"
---

## 1. Overview

The `trigger-docs-reusable.yml` workflow is a reusable GitHub Actions workflow that enables dependent repositories
(bash-compiler, bash-tools, bash-tools-framework, bash-dev-env) to trigger documentation builds in the centralized
my-documents orchestrator.

**Benefits:**

- **No secrets required** in dependent repositories (GitHub handles authentication automatically)
- **Centralized configuration** - All authentication handled by GitHub App in my-documents
- **Configurable** - Override defaults for organization, repository, URLs, etc.
- **Secure** - Uses GitHub App authentication with automatic token expiration
- **Simple integration** - Just a few lines in dependent repo workflows

## 2. Quick Start

### 2.1. Basic Usage

Create `.github/workflows/trigger-docs.yml` in your dependent repository:

```yaml
---
name: Trigger Documentation Build

on:
  push:
    branches: [master]
    paths:
      - 'content/**'
      - 'static/**'
      - 'go.mod'
      - 'go.sum'
  workflow_dispatch:

jobs:
  trigger-docs:
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    secrets: inherit
```

That's it! No secrets to configure, no tokens to manage.

## 3. How It Works

### 3.1. Architecture

```text
      ┌─────────────────────────┐
      │  Dependent Repository   │
      │  (e.g., bash-compiler)  │
      │                         │
      │  Push to master branch  │
      │  ├─ content/**          │
      │  └─ static/**           │
      └────────────┬────────────┘
                   │
                   │ workflow_call
                   ▼
┌─────────────────────────────────────┐
│  my-documents Repository            │
│                                     │
│  .github/workflows/                 │
│    trigger-docs-reusable.yml        │
│                                     │
│  ┌────────────────────────────────┐ │
│  │ 1. Generate GitHub App Token   │ │
│  │    (using DOC_APP_ID secret)   │ │
│  └────────────┬───────────────────┘ │
│               │                     │
│  ┌────────────▼───────────────────┐ │
│  │ 2. Trigger repository_dispatch │ │
│  │    event in my-documents       │ │
│  └────────────┬───────────────────┘ │
└───────────────┼─────────────────────┘
                │
                │ repository_dispatch
                ▼
┌─────────────────────────────────────┐
│  my-documents Repository            │
│                                     │
│  .github/workflows/                 │
│    build-all-sites.yml              │
│                                     │
│  Builds all 5 documentation sites   │
│  Deploys to GitHub Pages            │
└─────────────────────────────────────┘
```

### 3.2. Authentication Flow

1. **Calling workflow runs** in dependent repository context
2. **Reusable workflow executes** in my-documents repository context
3. **GitHub App token generated** using my-documents secrets:
   - `DOC_APP_ID` - GitHub App ID
   - `DOC_APP_PRIVATE_KEY` - GitHub App private key
4. **Token used to trigger** `repository_dispatch` event
5. **Build workflow starts** automatically in my-documents

**Security Benefits:**

- No PAT tokens needed in dependent repositories
- No secrets management in dependent repos
- Automatic token expiration (1 hour)
- Fine-grained permissions (Contents: write, Pages: write)
- Centralized audit trail

## 4. Configuration

### 4.1. Input Parameters

All inputs are optional with sensible defaults:

| Input              | Description                     | Default                              |
| ------------------ | ------------------------------- | ------------------------------------ |
| `target_org`       | Target organization/user        | `fchastanet`                         |
| `target_repo`      | Target repository name          | `my-documents`                       |
| `event_type`       | Repository dispatch event type  | `trigger-docs-rebuild`               |
| `docs_url_base`    | Documentation URL base          | `https://fchastanet.github.io`       |
| `workflow_filename`| Workflow filename to monitor    | `build-all-sites.yml`                |
| `source_repo`      | Source repository               | `${{ github.repository }}`           |
|                    | (auto-detected if not provided) |                                      |

### 4.2. Advanced Usage Examples

#### 4.2.1. Custom Documentation URL

```yaml
jobs:
  trigger-docs:
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    with:
      docs_url_base: 'https://docs.example.com'
    secrets: inherit
```

#### 4.2.2. Different Target Repository

```yaml
jobs:
  trigger-docs:
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    with:
      target_org: 'myOrg'
      target_repo: 'my-docs'
      workflow_filename: 'build-docs.yml'
    secrets: inherit
```

#### 4.2.3. Manual Trigger with Custom Event Type

```yaml
jobs:
  trigger-docs:
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    with:
      event_type: 'custom-docs-rebuild'
    secrets: inherit
```

## 5. Complete Example

Here's a complete example for a dependent repository:

```yaml
---
name: Trigger Documentation Build

on:
  # Trigger on content changes
  push:
    branches: [master]
    paths:
      - 'content/**'      # Hugo content
      - 'static/**'       # Static assets
      - 'go.mod'          # Hugo modules
      - 'go.sum'          # Hugo module checksums
      - 'configs/**'      # If using custom configs

  # Allow manual triggering
  workflow_dispatch:

  # Trigger on releases
  release:
    types: [published]

jobs:
  trigger-docs:
    name: Trigger Documentation Build
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    secrets: inherit
```

## 6. Secrets Configuration

### 6.1. In my-documents Repository

The reusable workflow requires these secrets to be configured in the my-documents repository:

| Secret                 | Description                         | How to Get                                 |
| ---------------------- | ----------------------------------- | ------------------------------------------ |
| `DOC_APP_ID`           | GitHub App ID                       | From GitHub App settings                   |
| `DOC_APP_PRIVATE_KEY`  | GitHub App private key (PEM format) | Generated when creating GitHub App         |

**Setting up secrets:**

1. Go to <https://github.com/fchastanet/my-documents/settings/secrets/actions>
2. Add `DOC_APP_ID` with your GitHub App ID
3. Add `DOC_APP_PRIVATE_KEY` with the private key content

### 6.2. In Dependent Repositories

**No secrets needed!** The `secrets: inherit` directive allows the reusable workflow to access my-documents secrets when
running.

## 7. Understanding Secrets: Inherit and Access Control

### 7.1. What is `secrets: inherit`?

`secrets: inherit` is a GitHub Actions feature that allows a reusable workflow to access **repository secrets from the
calling workflow's repository** when in the same repository context.

**Important distinction:**

When a dependent repository (like bash-compiler) calls this reusable workflow with `secrets: inherit`:

```yaml
jobs:
  trigger-docs:
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    secrets: inherit
```

It means:

> "Pass any secrets from bash-compiler repository to the reusable workflow"

NOT:

> "Pass secrets from my-documents to bash-compiler"

### 7.2. How Does It Work for Dependent Repositories?

The key to understanding this is the **execution context**:

1. **Workflow file location:** `.github/workflows/trigger-docs-reusable.yml` lives in **my-documents**
2. **Calling workflow location:** `.github/workflows/trigger-docs.yml` lives in **bash-compiler** (or other dependent repo)
3. **Execution context:** When bash-compiler calls the reusable workflow, the reusable workflow **still runs in the
   my-documents context**

This means:

- The reusable workflow has access to **my-documents' secrets**, not bash-compiler's secrets
- `secrets: inherit` tells the reusable workflow "use my (the calling repo's) secrets if needed"
- But since the workflow runs in my-documents context, it automatically has access to my-documents' secrets anyway

### 7.3. Secret Access Hierarchy

**GitHub Actions processes reusable workflows within the repository where they're defined:**

```text
┌────────────────────────────────────────────────────────────────────────────────────┐
│  bash-compiler repo                                                                │
│                                                                                    │
│  .github/workflows/                                                                │
│    trigger-docs.yml                                                                │
│                                                                                    │
│  calls: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master │
│    secrets: inherit                                                                │
└───────────────────────────────────────┬────────────────────────────────────────────┘
                                        │
                                        │ workflow_call (context: my-documents)
                                        │
                                        ▼
                      ┌─────────────────────────────────┐
                      │  my-documents repo              │
                      │  (workflow context)             │
                      │                                 │
                      │  .github/workflows/             │
                      │    trigger-docs-reusable.yml    │
                      │                                 │
                      │  ✅ Can access:                 │
                      │  - DOC_APP_ID                   │
                      │  - DOC_APP_PRIVATE_KEY          │
                      │  (my-documents secrets)         │
                      │                                 │
                      │  ❌ Cannot directly access:     │
                      │  - bash-compiler secrets        │
                      └─────────────────────────────────┘
```

### 7.4. Why This Workflow Can't Be Used by Others

**This workflow is tightly coupled to the my-documents infrastructure:**

#### 7.4.1. Reason 1: GitHub App is Organization-Specific

The workflow uses `DOC_APP_ID` and `DOC_APP_PRIVATE_KEY` secrets that are:

- Configured **only** in the my-documents repository
- Created from a GitHub App installed **only** on:
  - fchastanet/my-documents
  - fchastanet/bash-compiler
  - fchastanet/bash-tools
  - fchastanet/bash-tools-framework
  - fchastanet/bash-dev-env

**If someone from outside this organization tries to use the workflow:**

```yaml
# In their-org/their-repo
jobs:
  trigger-docs:
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    secrets: inherit
```

**What happens:**

1. Workflow starts in their-org/their-repo context (calling workflow)
2. Reusable workflow executes in **fchastanet/my-documents** context
3. Reusable workflow tries to access `DOC_APP_ID` and `DOC_APP_PRIVATE_KEY`
4. **These secrets don't exist** in their-repo, so `secrets: inherit` doesn't provide them
5. The workflow **fails with authentication error**

```text
Error: The variable has not been set, or it has been set to an empty string.
Evaluating: secrets.DOC_APP_ID
```

#### 7.4.2. Reason 2: GitHub App Has No Access to Other Organizations

The GitHub App is installed **only** on specific fchastanet repositories:

- When workflow tries to trigger `repository_dispatch` in my-documents using the app token
- The token is only valid for repositories where the app is **installed**
- If someone tries to point it to their own my-documents fork, the app has no permission

**Error example:**

```text
Error: Resource not accessible by integration
  at https://api.github.com/repos/their-org/their-docs/dispatches
```

#### 7.4.3. Reason 3: Secrets Are Repository-Specific

GitHub Actions secrets are stored at three levels:

| Level            | Scope                            | Accessible By                         |
| ---------------- | -------------------------------- | ------------------------------------- |
| **Repository**   | Single repository                | Workflows in that repository only     |
| **Environment**  | Specific deployment environment  | Workflows targeting that environment  |
| **Organization** | All repositories in organization | All workflows in the organization     |

My-documents secrets are stored at the **repository level**:

- Only accessible to workflows executing in my-documents context
- Not accessible to workflows in other organizations
- Not inherited by other repositories, even if they call the reusable workflow

### 7.5. Practical Example: Why It Fails

**Scenario:** User `john` forks my-documents to `john/my-documents-fork` and tries to use the workflow:

```yaml
# In john/bash-compiler (dependent repo fork)
jobs:
  trigger-docs:
    uses: john/my-documents-fork/.github/workflows/trigger-docs-reusable.yml@master
    secrets: inherit
```

**Execution flow:**

```text
1. bash-compiler workflow starts (context: john)
   ❌ john/my-documents-fork doesn't have DOC_APP_ID or DOC_APP_PRIVATE_KEY secrets

2. Reusable workflow starts (context: john/my-documents-fork)
   ❌ Tries to access secrets.DOC_APP_ID
   ❌ Secrets don't exist in john/my-documents-fork
   ❌ secrets: inherit doesn't help (no secrets in john/bash-compiler either)

3. GitHub App access attempt
   ❌ GitHub App not installed on john/my-documents-fork
   ❌ Authentication fails with 403 error
```

### 7.6. How Someone Else Could Create Their Own Version

**If someone wanted to use this pattern for their own orchestrator:**

1. **Create their own GitHub App**
   - In their organization settings
   - With Contents: write and Pages: write permissions
   - Install on their repositories

2. **Set up secrets in their my-documents repository**

   ```text
   DOC_APP_ID = their-app-id
   DOC_APP_PRIVATE_KEY = their-private-key
   ```

3. **Create their own reusable workflow**
   - Copy and adapt the trigger-docs-reusable.yml
   - Reference their own secrets
   - Change target_org default to their organization

4. **Update dependent repositories**
   - Point to their reusable workflow
   - Use `secrets: inherit` in their calls

**Example for their-org:**

```yaml
# In their-org/bash-compiler
jobs:
  trigger-docs:
    uses: their-org/my-docs-orchestrator/.github/workflows/trigger-docs-reusable.yml@master
    secrets: inherit
    # This now references their-org's secrets, not fchastanet's
```

### 7.7. Summary: Why This Workflow is Fchastanet-Only

| Component                      | Why It's Fchastanet-Specific         | Can Be Generalized?             |
| ------------------------------ | ------------------------------------ | ------------------------------- |
| Workflow logic                 | Generic, reusable for any workflow   | ✅ Yes, with different inputs   |
| `DOC_APP_ID` secret            | Specific to fchastanet's GitHub App  | ❌ No, organization-specific    |
| `DOC_APP_PRIVATE_KEY` secret   | Specific to fchastanet's GitHub App  | ❌ No, organization-specific    |
| Target repository (default)    | Hardcoded to my-documents            | ✅ Yes, via `target_repo` input |
| Target organization (default)  | Hardcoded to fchastanet              | ✅ Yes, via `target_org` input  |
| GitHub App installation        | Only on fchastanet repositories      | ❌ No, would need own app       |

### 7.8. Conclusion

The `secrets: inherit` mechanism is elegant for internal workflows within an organization because:

- **For dependent repos in fchastanet:** They can call the workflow without managing secrets (works perfectly)
- **For external users:** They cannot use this workflow as-is because the GitHub App and secrets are organization-specific
- **This is intentional:** It provides security and prevents unauthorized access to the build orchestration

This is **not a limitation** but a **security feature** - the workflow is designed to work only within the fchastanet
organization where the GitHub App is installed.

## 8. Workflow Outputs

The workflow provides rich output and summaries:

### 8.1. Console Output

```text
🔔 Triggering documentation build in fchastanet/my-documents...
✅ Successfully triggered docs build in fchastanet/my-documents
📖 Documentation will be updated at: https://fchastanet.github.io/bash-compiler/
ℹ️  Note: Documentation deployment may take 2-5 minutes
```

### 8.2. GitHub Actions Summary

The workflow creates a detailed summary visible in the Actions UI:

```markdown
### 8.3. ✅ Documentation build triggered

**Source Repository:** `fchastanet/bash-compiler`
**Target Repository:** `fchastanet/my-documents`
**Commit:** `abc123def456`
**Triggered by:** `fchastanet`

🔗 [View build status](https://github.com/fchastanet/my-documents/actions/workflows/build-all-sites.yml)
📖 [View documentation](https://fchastanet.github.io/bash-compiler/)
```

## 9. Troubleshooting

### 9.1. Build Not Triggered

**Symptoms:**

- Workflow runs successfully but build doesn't start
- HTTP 204 response but no activity in my-documents

**Possible Causes:**

1. **GitHub App not installed** on target repository
   - Solution: Install the GitHub App on my-documents repository

2. **GitHub App permissions insufficient**
   - Solution: Ensure app has `Contents: write` permission

3. **Event type mismatch**
   - Solution: Verify `event_type` input matches what build-all-sites.yml expects

### 9.2. Authentication Failures

**Symptoms:**

- HTTP 401 (Unauthorized) or 403 (Forbidden) errors
- "Resource not accessible by integration" error

**Possible Causes:**

1. **Secrets not configured** in my-documents
   - Solution: Add `DOC_APP_ID` and `DOC_APP_PRIVATE_KEY` secrets

2. **GitHub App private key incorrect**
   - Solution: Regenerate private key in GitHub App settings

3. **GitHub App permissions revoked**
   - Solution: Reinstall GitHub App on repositories

### 9.3. Workflow Not Found

**Symptoms:**

- "Unable to resolve action" error
- "Workflow file not found" error

**Possible Causes:**

1. **Wrong branch reference**
   - Solution: Use `@master` not `@main` (my-documents uses master branch)

2. **Workflow file renamed or moved**
   - Solution: Verify file exists at `.github/workflows/trigger-docs-reusable.yml`

### 9.4. Debug Mode

Enable debug logging in dependent repository:

```yaml
jobs:
  trigger-docs:
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    secrets: inherit
```

Then enable debug logs in repository settings:

1. Go to repository settings → Secrets and variables → Actions
2. Add repository variable: `ACTIONS_STEP_DEBUG` = `true`
3. Add repository variable: `ACTIONS_RUNNER_DEBUG` = `true`

## 10. Migration Guide

### 10.1. From Old Trigger Workflow

If you're migrating from the old PAT-based trigger workflow:

**Old approach (deprecated):**

```yaml
jobs:
  trigger:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger my-documents build
        run: |
          curl -X POST \
            -H "Authorization: token ${{ secrets.DOCS_BUILD_TOKEN }}" \
            ...
```

**New approach (recommended):**

```yaml
jobs:
  trigger-docs:
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    secrets: inherit
```

**Benefits of migration:**

- ✅ Remove `DOCS_BUILD_TOKEN` secret from dependent repository
- ✅ Simpler workflow (3 lines vs 50+ lines)
- ✅ Centralized authentication
- ✅ Automatic token management
- ✅ Better security (GitHub App vs PAT)

## 11. Best Practices

### 11.1. Trigger Paths

Only trigger on content changes to avoid unnecessary builds:

```yaml
on:
  push:
    branches: [master]
    paths:
      - 'content/**'      # Documentation content
      - 'static/**'       # Static assets
      - 'go.mod'          # Hugo modules (theme updates)
      - 'go.sum'
```

**Don't trigger on:**

- Test files
- CI configuration changes
- Source code changes (unless they affect docs)
- README updates (unless it's documentation content)

### 11.2. Concurrency Control

Prevent multiple concurrent builds:

```yaml
jobs:
  trigger-docs:
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    secrets: inherit
    concurrency:
      group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
      cancel-in-progress: true
```

### 11.3. Conditional Triggers

Only trigger for certain branches:

```yaml
jobs:
  trigger-docs:
    if: github.ref == 'refs/heads/master'
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    secrets: inherit
```

## 12. FAQ

### 12.1. Q: Do I need to configure secrets in my dependent repository?

**A:** No! When using `secrets: inherit`, the reusable workflow can access secrets from my-documents repository.

### 12.2. Q: Can I test the workflow before merging to master?

**A:** Yes, add `workflow_dispatch` trigger and manually run it from the Actions tab.

### 12.3. Q: How long does documentation deployment take?

**A:** Typically 2-5 minutes:

- Trigger: ~5 seconds
- Build (all sites): ~60 seconds
- Deployment: ~1-3 minutes (GitHub Pages propagation)

### 12.4. Q: Can I use this with my own organization?

**A:** Yes, override `target_org` and `target_repo` inputs. You'll need to set up your own GitHub App.

### 12.5. Q: What if the build fails?

**A:** Check the build status link in the workflow summary. The trigger workflow will still succeed; failures happen in
the build workflow.

### 12.6. Q: Can I trigger builds for multiple repositories?

**A:** Yes, create multiple jobs in your workflow, each calling the reusable workflow with different `source_repo`
values.

## 13. Related Documentation

- [Multi-Site Orchestrator Architecture](../../../.github/copilot-instructions.md#multi-site-orchestrator-architecture)
- [GitHub App Migration Guide](./2026-02-18-github-app-migration.md)
- [Build All Sites Workflow](../.github/workflows/build-all-sites.yml)

## 14. Support

For issues or questions:

1. Check [Troubleshooting](#9-troubleshooting) section
2. Review [GitHub Actions logs](https://github.com/fchastanet/my-documents/actions)
3. Create an issue in [my-documents repository](https://github.com/fchastanet/my-documents/issues)
