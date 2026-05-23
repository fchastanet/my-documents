#!/bin/bash
# Initialize Go modules for a site
# Usage: ./initialize-modules.sh BUILD_DIR [SITE_NAME]
# Example: ./initialize-modules.sh orchestrator

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

BUILD_DIR="${1:?Error: BUILD_DIR argument required}"
SITE_NAME="${2:-site}"

if [[ ! -f "${BUILD_DIR}/go.mod" ]]; then
  echo -e "${COLOR_ERROR}✗ go.mod not found in ${BUILD_DIR}${COLOR_RESET}"
  exit 1
fi
echo -e "${COLOR_INFO}Initializing Go modules for ${SITE_NAME}...${COLOR_RESET}"

(
  cd "${BUILD_DIR}"

  echo "  Downloading Hugo modules..."
  go get -u ./...

  echo -e "${COLOR_SUCCESS}✅ Go modules ready${COLOR_RESET}"
)
