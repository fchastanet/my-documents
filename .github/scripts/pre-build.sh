#!/bin/bash
# Pre-build script for my-documents
# Generates Marp presentations before Hugo build

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh" 2>/dev/null || {
  # Define basic colors if common.sh is not available
  BLUE='\033[0;34m'
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color
}

echo -e "${BLUE}Running pre-build for my-documents...${NC}"

# Determine the repository root
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$(dirname "${script_dir}")")"

# Build Marp presentations
if [[ -d "${repo_root}/marp" ]]; then
  "${script_dir}/build-marp.sh" "marp" "${repo_root}/static/presentations"
  echo -e "${GREEN}✅ Marp presentations built${NC}"
else
  echo -e "${BLUE}No marp directory found, skipping Marp build${NC}"
fi

echo -e "${GREEN}✅ Pre-build complete${NC}"
