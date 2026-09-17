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
  # Download the versions pinned in go.mod. `go get -u ./...` was used here
  # before, but it silently upgrades the theme, so a CI build could ship a
  # different Docsy than the one committed. Use `make upgrade-modules` to bump.
  go mod download

  echo -e "${COLOR_SUCCESS}✅ Go modules ready${COLOR_RESET}"
)
