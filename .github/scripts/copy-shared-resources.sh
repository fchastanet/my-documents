#!/bin/bash
# Copy shared resources (layouts, assets, archetypes) to build directory
# Usage: ./copy-shared-resources.sh SOURCE_DIR TARGET_DIR
# Example: ./copy-shared-resources.sh orchestrator/shared build/bash-compiler

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

SOURCE_DIR="${1:?Error: SOURCE_DIR argument required}"
TARGET_DIR="${2:?Error: TARGET_DIR argument required}"

if [ ! -d "$SOURCE_DIR" ]; then
  echo -e "${RED}✗ Source directory not found: $SOURCE_DIR${NC}"
  exit 1
fi

mkdir -p "$TARGET_DIR"

echo -e "${BLUE}Copying shared resources from $SOURCE_DIR...${NC}"
cp -r "$SOURCE_DIR"/* "$TARGET_DIR/"

echo -e "${GREEN}✅ Shared resources copied${NC}"
