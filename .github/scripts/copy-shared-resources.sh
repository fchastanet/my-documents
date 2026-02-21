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

# Copy layouts
if [ -d "$SOURCE_DIR/layouts" ]; then
  echo "  Copying shared layouts..."
  mkdir -p "$TARGET_DIR/layouts"
  cp -r "$SOURCE_DIR/layouts"/* "$TARGET_DIR/layouts/"
fi

# Copy assets
if [ -d "$SOURCE_DIR/assets" ]; then
  echo "  Copying shared assets..."
  mkdir -p "$TARGET_DIR/assets"
  cp -r "$SOURCE_DIR/assets"/* "$TARGET_DIR/assets/"
fi

# Copy archetypes
if [ -d "$SOURCE_DIR/archetypes" ]; then
  echo "  Copying shared archetypes..."
  mkdir -p "$TARGET_DIR/archetypes"
  cp -r "$SOURCE_DIR/archetypes"/* "$TARGET_DIR/archetypes/"
fi

echo -e "${GREEN}✅ Shared resources copied${NC}"
