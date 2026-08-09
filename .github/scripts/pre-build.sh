#!/bin/bash
# Pre-build script for my-documents
# Generates Marp presentations before Hugo build

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh" 2>/dev/null

echo -e "${COLOR_INFO}Running pre-build for my-documents...${COLOR_RESET}"

# Determine the repository root
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$(dirname "${script_dir}")")"

# ensure hugo and node dependencies are installed
"$(dirname "$0")/install-hugo.sh"

# Build Marp presentations
if [[ -d "${repo_root}/marp" ]]; then
  "${script_dir}/build-marp.sh" "marp" "${repo_root}/static/presentations"
  echo -e "${COLOR_SUCCESS}✅ Marp presentations built${COLOR_RESET}"
else
  echo -e "${COLOR_INFO}No marp directory found, skipping Marp build${COLOR_RESET}"
fi

echo -e "${COLOR_SUCCESS}✅ Pre-build complete${COLOR_RESET}"
