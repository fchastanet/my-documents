#!/bin/bash
# Build all sites locally
# Usage: ./build-all.sh [BUILD_DIR] [SITES_DIR] [REPOS...]
# Example: ./build-all.sh build sites bash-compiler bash-tools bash-tools-framework bash-dev-env

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

BUILD_DIR="${1:-build}"
SITES_DIR="${2:-sites}"
shift 2 || true
REPOS=("$@")

if [[ "${#REPOS[@]}" = "0" ]]; then
  echo -e "${COLOR_WARNING}No repositories specified${COLOR_RESET}"
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$(dirname "${script_dir}")")"

(
  cd "${repo_root}"

  echo -e "${COLOR_INFO}Building all sites...${COLOR_RESET}"

  # Build my-documents
  "${script_dir}/build-site.sh" "${repo_root}" "my-documents" "${BUILD_DIR}"

  # Build other sites
  for repo in "${REPOS[@]}"; do
    "${script_dir}/build-site.sh" "${SITES_DIR}/${repo}" "${repo}" "${BUILD_DIR}"
  done
)

echo -e "${COLOR_SUCCESS}✅ All sites built successfully${COLOR_RESET}"
