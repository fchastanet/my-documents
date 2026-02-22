#!/bin/bash
# Prepare build directory for a site
# Handles both orchestrator (my-documents) and dependent site builds
# Usage: ./prepare-build.sh SITE_NAME ORCHESTRATOR_DIR SOURCE_DIR OUTPUT_DIR [BASE_URL]
# Example: ./prepare-build.sh my-documents orchestrator . . "https://fchastanet.github.io/my-documents"
# Example: ./prepare-build.sh bash-compiler orchestrator sites/bash-compiler build/bash-compiler "https://fchastanet.github.io/bash-compiler"

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

SITE_NAME="${1:?Error: SITE_NAME argument required}"
ORCHESTRATOR_DIR="${2:?Error: ORCHESTRATOR_DIR argument required}"
SOURCE_DIR="${3:?Error: SOURCE_DIR argument required}"
OUTPUT_DIR="${4:?Error: OUTPUT_DIR argument required}"
BASE_URL="${5:-}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Preparing build for $SITE_NAME...${NC}"

# For dependent sites
echo "  Setting up dependent site..."
mkdir -p "$OUTPUT_DIR"

# Copy shared resources from orchestrator
"$script_dir/copy-shared-resources.sh" \
  "$ORCHESTRATOR_DIR/shared" \
  "$OUTPUT_DIR"

# Copy site content
echo "  Copying content..."
if [ -d "$SOURCE_DIR/content" ]; then
  cp -r "$SOURCE_DIR/content" "$OUTPUT_DIR/"
else
  echo -e "${YELLOW}⚠ No content directory found in $SOURCE_DIR${NC}"
fi

echo "  Copying static files..."
if [ -d "$SOURCE_DIR/static" ]; then
  cp -r "$SOURCE_DIR/static" "$OUTPUT_DIR/"
fi

# Copy go.mod and go.sum if they exist
if [ -f "$SOURCE_DIR/go.mod" ]; then
  cp "$SOURCE_DIR/go.mod" "$OUTPUT_DIR/"
fi
if [ -f "$SOURCE_DIR/go.sum" ]; then
  cp "$SOURCE_DIR/go.sum" "$OUTPUT_DIR/"
fi

# Merge configurations
echo "  Merging configurations..."
"$script_dir/merge-configs.sh" \
  "$ORCHESTRATOR_DIR/configs/_base.yaml" \
  "$ORCHESTRATOR_DIR/configs/$SITE_NAME.yaml" \
  "$OUTPUT_DIR/hugo.yaml" \
  "$BASE_URL"

# Copy go.mod and go.sum from orchestrator if not present in site
if [[ -f "$ORCHESTRATOR_DIR/go.mod" && ! -f "$OUTPUT_DIR/go.mod" ]]; then
  echo "  Copying go.mod from orchestrator..."
  cp "$ORCHESTRATOR_DIR/go.mod" "$OUTPUT_DIR/"
fi
if [[ -f "$ORCHESTRATOR_DIR/go.sum" && ! -f "$OUTPUT_DIR/go.sum" ]]; then
  echo "  Copying go.sum from orchestrator..."
  cp "$ORCHESTRATOR_DIR/go.sum" "$OUTPUT_DIR/"
fi

echo -e "${GREEN}✅ Build directory prepared for $SITE_NAME${NC}"
