#!/bin/bash
# Build all sites locally
# Usage: ./build-all.sh [BUILD_DIR] [SITES_DIR] [REPOS...]
# Example: ./build-all.sh build sites bash-compiler bash-tools bash-tools-framework bash-dev-env

source "$(dirname "$0")/common.sh"

BUILD_DIR="${1:-build}"
SITES_DIR="${2:-sites}"
shift 2 || true
REPOS=("$@")

if [ ${#REPOS[@]} -eq 0 ]; then
  echo -e "${YELLOW}No repositories specified${NC}"
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$(dirname "$script_dir")")"

(
  cd "$repo_root"

  echo -e "${BLUE}Building all sites...${NC}"

  # Build my-documents
  "$script_dir/build-site.sh" "$repo_root" "my-documents" "$BUILD_DIR"

  # Build other sites
  for repo in "${REPOS[@]}"; do
    "$script_dir/build-site.sh" "${SITES_DIR}/${repo}" "$repo" "$BUILD_DIR"
  done
)

echo -e "${GREEN}✅ All sites built successfully${NC}"
