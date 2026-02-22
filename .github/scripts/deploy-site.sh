#!/bin/bash
# Deploy site to GitHub Pages using GitHub App token
# Usage: ./deploy-site.sh SITE_NAME PUBLIC_DIR EXTERNAL_REPO [GITHUB_TOKEN]
# Example: ./deploy-site.sh bash-compiler build/bash-compiler/public fchastanet/bash-compiler
# If EXTERNAL_REPO is empty, uses default GITHUB_TOKEN environment variable

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

SITE_NAME="${1:?Error: SITE_NAME argument required}"
PUBLIC_DIR="${2:?Error: PUBLIC_DIR argument required}"
EXTERNAL_REPO="${3:-}"
GITHUB_TOKEN="${4:-${GITHUB_TOKEN:-}}"

if [ ! -d "$PUBLIC_DIR" ]; then
  echo -e "${RED}✗ Public directory not found: $PUBLIC_DIR${NC}"
  exit 1
fi

if [ -z "$EXTERNAL_REPO" ] && [ -z "$GITHUB_TOKEN" ]; then
  # For self (my-documents), GITHUB_TOKEN should be set by GitHub Actions
  if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo -e "${RED}✗ GITHUB_TOKEN not provided and not set in environment${NC}"
    exit 1
  fi
fi

echo -e "${BLUE}Deploying $SITE_NAME to GitHub Pages...${NC}"
echo "  Site: $SITE_NAME"
echo "  Public Dir: $PUBLIC_DIR"
if [ -n "$EXTERNAL_REPO" ]; then
  echo "  External Repo: $EXTERNAL_REPO"
fi

# Configuration for git in the context of GitHub Actions
git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"

# Output size information
echo "  📊 Directory size: $(du -sh "$PUBLIC_DIR" | cut -f1)"
echo "  📄 HTML files: $(find "$PUBLIC_DIR" -name '*.html' | wc -l)"

echo -e "${GREEN}✅ Deployment configuration ready${NC}"
echo "(Note: Actual deployment handled by peaceiris/actions-gh-pages@v4 action)"
