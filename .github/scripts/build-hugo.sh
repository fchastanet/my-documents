#!/bin/bash
# Build site with Hugo
# Usage: ./build-hugo.sh BUILD_DIR [SITE_NAME] [BASE_URL]
# Example: ./build-hugo.sh orchestrator my-documents "https://devlab.top"

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"
ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd -P)"

BUILD_DIR="${1:?Error: BUILD_DIR argument required}"
SITE_NAME="${2:-site}"
BASE_URL="${3:-}"

if [[ ! -d "${BUILD_DIR}" ]]; then
  echo -e "${COLOR_ERROR}✗ Build directory not found: ${BUILD_DIR}${COLOR_RESET}"
  exit 1
fi

# ensure hugo is installed
"$(dirname "$0")/install-hugo.sh"

echo -e "${COLOR_INFO}Building ${SITE_NAME} with Hugo...${COLOR_RESET}"

(
  cd "${BUILD_DIR}" || exit 1

  # Set environment variables for Hugo build
  export HUGO_CACHEDIR="${HUGO_CACHEDIR:-$(cd ".." && pwd -P)/.hugo_cache}"
  export HUGO_ENVIRONMENT="${HUGO_ENVIRONMENT:-production}"
  export PATH="${PATH}:${ROOT_DIR}/node_modules/.bin"

  # Build with all diagnostic flags
  echo "  Running: hugo --minify with base URL: ${BASE_URL:-(from config)}"

  args=()
  if [[ "${BUILD:-0}" = "0" ]]; then
    args+=(
      server
      --disableFastRender
    )
  fi
  args+=(
    --minify
    --printI18nWarnings
    --printPathWarnings
    --printUnusedTemplates
    --logLevel info
  )
  if [[ -n "${BASE_URL}" ]]; then
    args+=(--baseURL "${BASE_URL}/")
  fi
  hugo "${args[@]}"

  echo -e "${COLOR_SUCCESS}✅ Build complete for ${SITE_NAME}${COLOR_RESET}"
  echo "  📊 Public directory size:"
  du -sh public/
)
