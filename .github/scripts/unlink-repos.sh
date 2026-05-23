#!/bin/bash
# Remove symlinks to other repositories
# Usage: ./unlink-repos.sh [SITES_DIR] [REPOS...]
# Example: ./unlink-repos.sh sites bash-compiler bash-tools bash-tools-framework bash-dev-env

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

SITES_DIR="${1:-.}"
shift || true
REPOS=("$@")

if [[ "${#REPOS[@]}" = "0" ]]; then
  echo -e "${COLOR_WARNING}No repositories specified${COLOR_RESET}"
  exit 1
fi

echo -e "${COLOR_INFO}Removing symlinks...${COLOR_RESET}"

for repo in "${REPOS[@]}"; do
  link_path="${SITES_DIR}/${repo}"

  if [[ -L "${link_path}" ]]; then
    rm "${link_path}"
    echo -e "  ${COLOR_SUCCESS}✓${COLOR_RESET} Removed ${link_path}"
  fi
done

# Remove sites directory if empty
if [[ -d "${SITES_DIR}" ]]; then
  rmdir "${SITES_DIR}" 2>/dev/null || true
  echo -e "${COLOR_SUCCESS}✓${COLOR_RESET} Removed empty ${SITES_DIR}"
fi

echo -e "${COLOR_SUCCESS}✅ Symlinks removed${COLOR_RESET}"
