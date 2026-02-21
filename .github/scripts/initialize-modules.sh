#!/bin/bash
# Initialize Go modules for a site
# Usage: ./initialize-modules.sh BUILD_DIR [SITE_NAME]
# Example: ./initialize-modules.sh orchestrator

set -euo pipefail
source "$(dirname "$0")/common.sh"

BUILD_DIR="${1:?Error: BUILD_DIR argument required}"
SITE_NAME="${2:-site}"

if [ ! -f "$BUILD_DIR/go.mod" ]; then
  echo -e "${RED}✗ go.mod not found in $BUILD_DIR${NC}"
  exit 1
fi
echo -e "${BLUE}Initializing Go modules for $SITE_NAME...${NC}"

(
  cd "$BUILD_DIR"

  echo "  Downloading Hugo modules..."
  go get -u ./...

  echo -e "${GREEN}✅ Go modules ready${NC}"
)
