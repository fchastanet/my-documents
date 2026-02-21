#!/bin/bash
# Create symlinks to other repositories for local testing
# Usage: ./link-repos.sh [SITES_DIR] [REPOS...]
# Example: ./link-repos.sh sites bash-compiler bash-tools bash-tools-framework bash-dev-env

source "$(dirname "$0")/common.sh"

PARENT_DIR=$(cd "$(dirname "$0")/../.." && pwd)
SITES_DIR="${1:-.}"
shift || true
REPOS=("$@")

if [ ${#REPOS[@]} -eq 0 ]; then
  echo -e "${YELLOW}No repositories specified${NC}"
  exit 1
fi

echo -e "${BLUE}Creating symlinks to other repositories...${NC}"

mkdir -p "$SITES_DIR"

for repo in "${REPOS[@]}"; do
  repo_parent_dir=$(cd "$(dirname "$PARENT_DIR")" && pwd)
  repo_path="${repo_parent_dir}/${repo}"
  link_path="${SITES_DIR}/${repo}"

  if [ -d "$repo_path" ]; then
    if [ -L "$link_path" ]; then
      echo -e "  ${YELLOW}✓${NC} ${link_path} already linked"
    else
      ln -sf "$repo_path" "$link_path"
      echo -e "  ${GREEN}✓${NC} Linked ${link_path} → ${repo_path}"
    fi
  else
    echo -e "  ${YELLOW}⚠${NC}  ${repo_path} not found (clone it to enable)"
  fi
done

echo -e "${GREEN}✅ Symlinks created${NC}"
