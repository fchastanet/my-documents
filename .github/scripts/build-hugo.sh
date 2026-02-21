#!/bin/bash
# Build site with Hugo
# Usage: ./build-hugo.sh BUILD_DIR [SITE_NAME] [BASE_URL]
# Example: ./build-hugo.sh orchestrator my-documents "https://fchastanet.github.io/my-documents"

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

BUILD_DIR="${1:?Error: BUILD_DIR argument required}"
SITE_NAME="${2:-site}"
BASE_URL="${3:-}"

if [[ ! -d "$BUILD_DIR" ]]; then
  echo -e "${RED}✗ Build directory not found: $BUILD_DIR${NC}"
  exit 1
fi

echo -e "${BLUE}Building $SITE_NAME with Hugo...${NC}"

(
  cd "$BUILD_DIR"

  # Set environment variables for Hugo build
  export HUGO_CACHEDIR="${HUGO_CACHEDIR:-$(pwd)/.hugo_cache}"
  export HUGO_ENVIRONMENT="${HUGO_ENVIRONMENT:-production}"

  # Build with all diagnostic flags
  echo "  Running: hugo --minify with base URL: ${BASE_URL:-(from config)}"

  args=(
    --minify
    --printI18nWarnings
    --printPathWarnings
    --printUnusedTemplates
    --logLevel info
  )
  if [[ -n "$BASE_URL" ]]; then
    args+=(--baseURL "$BASE_URL/")
  fi
  hugo "${args[@]}"

  echo -e "${GREEN}✅ Build complete for $SITE_NAME${NC}"
  echo "  📊 Public directory size:"
  du -sh public/
)
