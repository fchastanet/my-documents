#!/bin/bash
# Create symlinks to other repositories for local testing
# Usage: ./link-repos.sh [SITES_DIR] [REPOS...]
# Example: ./link-repos.sh sites bash-compiler bash-tools bash-tools-framework bash-dev-env

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

PARENT_DIR=$(cd "$(dirname "$0")/../.." && pwd)
SITES_DIR="${1:-.}"
shift || true
REPOS=("$@")

if [[ "${#REPOS[@]}" = "0" ]]; then
  echo -e "${COLOR_WARNING}No repositories specified${COLOR_RESET}"
  exit 1
fi

echo -e "${COLOR_INFO}Creating symlinks to other repositories...${COLOR_RESET}"

mkdir -p "${SITES_DIR}"

for repo in "${REPOS[@]}"; do
  repo_parent_dir=$(cd "$(dirname "${PARENT_DIR}")" && pwd)
  repo_path="${repo_parent_dir}/${repo}"
  link_path="${SITES_DIR}/${repo}"

  if [[ -d "${repo_path}" ]]; then
    if [[ -L "${link_path}" ]]; then
      echo -e "  ${COLOR_WARNING}✓${COLOR_RESET} ${link_path} already linked"
    else
      ln -sf "${repo_path}" "${link_path}"
      echo -e "  ${COLOR_SUCCESS}✓${COLOR_RESET} Linked ${link_path} → ${repo_path}"
    fi
  else
    echo -e "  ${COLOR_WARNING}⚠${COLOR_RESET}  ${repo_path} not found (clone it to enable)"
  fi
done

echo -e "${COLOR_SUCCESS}✅ Symlinks created${COLOR_RESET}"
