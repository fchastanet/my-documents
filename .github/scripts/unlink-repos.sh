#!/bin/bash
# Remove symlinks to other repositories
# Usage: ./unlink-repos.sh [SITES_DIR] [REPOS...]
# Example: ./unlink-repos.sh sites bash-compiler bash-tools bash-tools-framework bash-dev-env

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

SITES_DIR="${1:-.}"
shift || true
REPOS=("$@")

if [ ${#REPOS[@]} -eq 0 ]; then
  echo -e "${YELLOW}No repositories specified${NC}"
  exit 1
fi

echo -e "${BLUE}Removing symlinks...${NC}"

for repo in "${REPOS[@]}"; do
  link_path="${SITES_DIR}/${repo}"

  if [ -L "$link_path" ]; then
    rm "$link_path"
    echo -e "  ${GREEN}✓${NC} Removed ${link_path}"
  fi
done

# Remove sites directory if empty
if [ -d "$SITES_DIR" ]; then
  rmdir "$SITES_DIR" 2>/dev/null || true
  echo -e "${GREEN}✓${NC} Removed empty ${SITES_DIR}"
fi

echo -e "${GREEN}✅ Symlinks removed${NC}"
