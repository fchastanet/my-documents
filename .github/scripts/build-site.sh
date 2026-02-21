#!/bin/bash
# Build a specific site locally
# Usage: ./build-site.sh SITE SITE_NAME [BUILD_DIR]
# Example: ./build-site.sh sites/bash-compiler bash-compiler build

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

if (( $# < 2 )); then
  echo -e "${YELLOW}Usage: $0 SITE SITE_NAME [BUILD_DIR]${NC}"
  echo -e "${YELLOW}Example: $0 sites/bash-compiler bash-compiler build${NC}"
  exit 1
fi

SITE_DIR="$1"
SITE_NAME="${2:-$(basename "$SITE_DIR")}"
BUILD_DIR="${3:-build}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$(dirname "$script_dir")")"

echo -e "${BLUE}Building ${SITE_NAME}...${NC}"

# Verify site directory exists
if [ ! -d "${SITE_DIR}" ]; then
  echo -e "${YELLOW}⚠  ${SITE_DIR} not found. Run 'make link-repos' first.${NC}"
  exit 1
fi

# Verify content exists
if [ ! -d "${SITE_DIR}/content" ]; then
  echo -e "${YELLOW}⚠  Skipping ${SITE_NAME} as ${SITE_DIR}/content not found.${NC}"
  exit 0
fi

output_dir="${BUILD_DIR}/${SITE_NAME}"

# Use prepare-build script to set up the build directory
"$script_dir/prepare-build.sh" \
  "$SITE_NAME" \
  "$repo_root" \
  "$SITE_DIR" \
  "$output_dir"

# Initialize Go modules
"$script_dir/initialize-modules.sh" \
  "$output_dir" \
  "$SITE_DIR"

# Build with Hugo
"$script_dir/build-hugo.sh" \
  "$output_dir" \
  "$SITE_DIR"

echo -e "${GREEN}✅ ${SITE_NAME} built successfully${NC}"
echo -e "  Output: ${output_dir}/public/"
