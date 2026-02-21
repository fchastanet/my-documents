# Improved Prompt: Transform Trigger Workflow to Reusable GitHub Action

**Date:** February 21, 2026
**Original Request:** Transform `.github/workflows/trigger-docs-reusable.yml` to reusable GitHub action
**Context:** Multi-site documentation orchestrator using Hugo

## Objective

Transform the existing trigger workflow into a reusable GitHub Actions workflow that can be called by dependent
repositories to trigger centralized documentation builds in my-documents, with the following requirements:

1. Make configurable with input parameters for easy customization
2. Eliminate need for PAT tokens in dependent repositories
3. Use GitHub App authentication for enhanced security
4. Create comprehensive documentation for users
5. Update README.md with quick reference

## Requirements Analysis

### Core Functionality

**Current State:**

- Workflow located in `.github/workflows/trigger-docs-reusable.yml`
- Uses PAT token (`DOCS_BUILD_TOKEN`) for authentication
- Hardcoded organization, repository, and URLs
- Intended to be copied to dependent repositories
- Triggers `repository_dispatch` event in my-documents

**Desired State:**

- Reusable workflow callable via `workflow_call`
- GitHub App authentication (no PAT needed in dependent repos)
- Configurable inputs for all key parameters
- Centralized in my-documents repository
- Single source of truth for all dependent repositories

### Technical Approach

#### Option 1: Reusable Workflow (Recommended)

**Implementation:**

- Change `on:` trigger to `workflow_call` with inputs
- Define input parameters with defaults
- Use secrets from my-documents repository
- Keep workflow in `.github/workflows/` directory

**Advantages:**

- No marketplace publication needed
- Native GitHub Actions feature
- Automatic authentication handling
- Simple reference: `uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master`
- Secrets managed centrally in my-documents

**Disadvantages:**

- Only works for workflows (not for direct action usage)
- Must reference specific repository and path

#### Option 2: Composite Action

**Implementation:**

- Create `action.yml` in repository root or subdirectory
- Package as composite action
- Can publish to GitHub Marketplace

**Advantages:**

- Can be published to marketplace for discoverability
- More portable across different contexts

**Disadvantages:**

- More complex setup
- Not needed for internal-only usage
- Marketplace publication overhead unnecessary

**Decision:** Use **Reusable Workflow** (Option 1) because:

- Cleaner for workflow-to-workflow communication
- No marketplace needed for internal tools
- Simpler maintenance
- Better secret management

### Configuration Parameters

**Required Inputs:**

| Input               | Purpose                                   | Default                        |
| ------------------- | ----------------------------------------- | ------------------------------ |
| `target_org`        | Organization hosting orchestrator         | `fchastanet`                   |
| `target_repo`       | Orchestrator repository name              | `my-documents`                 |
| `event_type`        | Repository dispatch event type            | `trigger-docs-rebuild`         |
| `docs_url_base`     | Base URL for documentation sites          | `https://fchastanet.github.io` |
| `workflow_filename` | Workflow to monitor in orchestrator       | `build-all-sites.yml`          |
| `source_repo`       | Repository triggering the build           | Auto-detected                  |

**Secrets (in my-documents):**

- `DOC_APP_ID` - GitHub App ID
- `DOC_APP_PRIVATE_KEY` - GitHub App private key

### Authentication Strategy

**GitHub App Benefits:**

1. **No PAT management** - Dependent repos don't need secrets
2. **Fine-grained permissions** - Only Contents and Pages access
3. **Automatic expiration** - Tokens expire in 1 hour
4. **Better audit trail** - App actions clearly attributed
5. **Centralized control** - All permissions and access managed in one place

**Implementation:**

```yaml
- name: Generate GitHub App token
  id: app-token
  uses: actions/create-github-app-token@v1
  with:
    app-id: ${{ secrets.DOC_APP_ID }}
    private-key: ${{ secrets.DOC_APP_PRIVATE_KEY }}
    owner: ${{ inputs.target_org }}
    repositories: ${{ inputs.target_repo }}
```

## Implementation Plan

### Phase 1: Transform Workflow

**File:** `.github/workflows/trigger-docs-reusable.yml`

**Changes:**

1. Update `on:` trigger:
   ```yaml
   on:
     workflow_call:
       inputs:
         target_org:
           description: 'Target organization/user'
           required: false
           type: string
           default: 'fchastanet'
         # ... other inputs
   ```

2. Add GitHub App token generation step

3. Update curl command to use inputs instead of hardcoded values

4. Enhance output with more detailed information

5. Update comments to reflect reusable workflow usage

### Phase 2: Documentation

**File:** `doc/trigger-my-documents-workflow.md`

**Sections:**

1. **Overview** - What it is, benefits, quick start
2. **How It Works** - Architecture diagram, authentication flow
3. **Configuration** - Input parameters table, advanced examples
4. **Complete Example** - Full workflow file for dependent repos
5. **Secrets Configuration** - Setup guide for my-documents
6. **Workflow Outputs** - Console output, GitHub Actions summary
7. **Troubleshooting** - Common issues and solutions
8. **Migration Guide** - From PAT-based to reusable workflow
9. **Best Practices** - Trigger paths, concurrency, conditionals
10. **FAQ** - Common questions and answers

### Phase 3: README Update

**File:** `README.md`

**Changes:**

1. Add new section: "Reusable Workflow for Dependent Repositories"
2. Include quick start example
3. Add link to full documentation
4. Highlight key benefits

### Phase 4: AI Documentation

**File:** `doc/ai/2026-02-21-reusable-trigger-workflow.md`

**Content:**

- Improved prompt with full context
- Requirements analysis
- Technical decision rationale
- Implementation details
- Testing strategy

## Testing Strategy

### Unit Testing

**Validate workflow syntax:**

```bash
# Use GitHub CLI or yamllint
yamllint .github/workflows/trigger-docs-reusable.yml
```

**Validate inputs:**

- Check all inputs have defaults
- Verify type specifications
- Ensure descriptions are clear

### Integration Testing

**Test Cases:**

1. **Default inputs** - Call without any inputs, verify defaults used
2. **Custom inputs** - Override each input, verify behavior
3. **Authentication** - Verify GitHub App token generation succeeds
4. **Trigger success** - Verify repository_dispatch event sent
5. **Error handling** - Test with invalid inputs, verify appropriate errors

**Test Workflow (in bash-compiler):**

```yaml
name: Test Trigger Workflow

on:
  workflow_dispatch:

jobs:
  test-default:
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    secrets: inherit

  test-custom:
    uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
    with:
      docs_url_base: 'https://test.example.com'
    secrets: inherit
```

### End-to-End Testing

**Scenario:**

1. Push docs change to dependent repository (e.g., bash-compiler)
2. Verify trigger workflow runs successfully
3. Verify my-documents build starts
4. Verify all 5 sites build successfully
5. Verify bash-compiler site deploys with changes

## Rollout Plan

### Step 1: Update my-documents

1. Update `.github/workflows/trigger-docs-reusable.yml`
2. Create `doc/trigger-my-documents-workflow.md`
3. Update `README.md`
4. Test locally (workflow syntax validation)
5. Commit to master branch

### Step 2: Test with One Dependent Repository

1. Choose bash-compiler as test repository
2. Update `.github/workflows/trigger-docs.yml`:
   ```yaml
   jobs:
     trigger-docs:
       uses: fchastanet/my-documents/.github/workflows/trigger-docs-reusable.yml@master
       secrets: inherit
   ```
3. Remove `DOCS_BUILD_TOKEN` secret (no longer needed)
4. Push test change to trigger workflow
5. Verify successful build

### Step 3: Migrate Remaining Repositories

1. Apply same changes to:
   - bash-tools
   - bash-tools-framework
   - bash-dev-env
2. Remove PAT secrets from each
3. Test each repository individually

### Step 4: Documentation Rollout

1. Announce in repository README
2. Update orchestrator documentation (`.github/copilot-instructions.md`)
3. Create migration guide for future repositories

## Success Criteria

**Functional Requirements:**

- ✅ Reusable workflow callable from dependent repositories
- ✅ All inputs configurable with sensible defaults
- ✅ GitHub App authentication working
- ✅ No secrets required in dependent repos
- ✅ Successful trigger of repository_dispatch event
- ✅ Clear output and summaries

**Documentation Requirements:**

- ✅ Comprehensive usage guide created
- ✅ README.md updated with reference
- ✅ Examples for basic and advanced usage
- ✅ Troubleshooting guide included
- ✅ Migration guide from PAT approach

**Quality Requirements:**

- ✅ Workflow passes YAML linting
- ✅ All links in documentation valid
- ✅ Code examples tested and working
- ✅ No breaking changes for existing users (if phased rollout)

## Benefits Summary

**For Repository Maintainers:**

- **Simplified setup** - 3 lines instead of 50+
- **No secret management** - No PAT tokens needed
- **Centralized updates** - Changes in one place affect all repos
- **Better security** - GitHub App tokens auto-expire

**For Security:**

- GitHub App with fine-grained permissions
- Automatic token rotation (1-hour lifetime)
- No long-lived PAT tokens
- Centralized access control

**For Maintenance:**

- Single source of truth in my-documents
- Easier updates and bug fixes
- Consistent behavior across all repos
- Better testability

## Risks and Mitigations

| Risk                                       | Impact | Mitigation                                       |
| ------------------------------------------ | ------ | ------------------------------------------------ |
| GitHub App permissions insufficient        | High   | Test thoroughly before rollout                   |
| Breaking change for existing workflows     | Medium | Phased rollout, document migration               |
| Workflow file not found error              | Medium | Use correct branch reference (@master not @main) |
| Secrets not accessible with secrets:inherit| High   | Verify GitHub App installed on target repo       |

## Future Enhancements

**Potential Improvements:**

1. **Conditional triggers** - Skip build if only comments changed
2. **Build preview** - Deploy to preview URL for PR builds
3. **Multi-site selection** - Allow triggering specific sites only
4. **Build caching** - Cache Hugo modules across builds
5. **Notification integration** - Slack/Discord notifications on build complete
6. **Metrics collection** - Track build times, success rates

## Related Documentation

- [GitHub App Migration](./2026-02-18-github-app-migration.md)
- [Multi-Site Orchestrator](./2026-02-18-hugo-multi-site-migration-strategy.md)
- [Build All Sites Workflow](../../.github/workflows/build-all-sites.yml)
- [Copilot Instructions](../../.github/copilot-instructions.md)

## Conclusion

This transformation simplifies the documentation trigger process for all dependent repositories while improving
security and maintainability. The reusable workflow approach is ideal for this use case because it:

1. Eliminates secret management burden from dependent repos
2. Provides centralized control and updates
3. Uses modern GitHub App authentication
4. Requires minimal changes in dependent repositories
5. Maintains backward compatibility through phased rollout

The comprehensive documentation ensures that any future repositories can easily integrate with the orchestrator, and
the troubleshooting guide helps resolve common issues quickly.
