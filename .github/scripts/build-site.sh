#!/bin/bash
# Build a specific site locally
# Usage: ./build-site.sh SITE [BUILD_DIR] [SITES_DIR]
# Example: ./build-site.sh bash-compiler build sites

source "$(dirname "$0")/common.sh"

SITE="${1:?Error: SITE argument required}"
BUILD_DIR="${2:-build}"
SITES_DIR="${3:-sites}"

if [ -z "$SITE" ]; then
  echo -e "${YELLOW}Usage: $0 SITE [BUILD_DIR] [SITES_DIR]${NC}"
  echo -e "${YELLOW}Example: $0 bash-compiler build sites${NC}"
  exit 1
fi

echo -e "${BLUE}Building ${SITE}...${NC}"

# Create build directory
mkdir -p "${BUILD_DIR}/${SITE}"

# Check if site directory exists
if [ ! -d "${SITES_DIR}/${SITE}" ]; then
  echo -e "${YELLOW}⚠  ${SITES_DIR}/${SITE} not found. Run 'make link-repos' first.${NC}"
  exit 1
fi

# Check if content exists
if [ ! -d "${SITES_DIR}/${SITE}/content" ]; then
  echo -e "${YELLOW}⚠  Skipping ${SITE} as ${SITES_DIR}/${SITE}/content not found.${NC}"
  exit 0
fi

# Copy shared resources
cp -r shared/* "${BUILD_DIR}/${SITE}/" 2>/dev/null || true

# Copy site content
cp -r "${SITES_DIR}/${SITE}/content" "${BUILD_DIR}/${SITE}/"
[ -d "${SITES_DIR}/${SITE}/static" ] && cp -r "${SITES_DIR}/${SITE}/static" "${BUILD_DIR}/${SITE}/" || true

# Merge configurations
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
  configs/_base.yaml "configs/${SITE}.yaml" > "${BUILD_DIR}/${SITE}/hugo.yaml"

# Copy go.mod if exists
if [ -f "${SITES_DIR}/${SITE}/go.mod" ]; then
  cp "${SITES_DIR}/${SITE}/go.mod" "${SITES_DIR}/${SITE}/go.sum" "${BUILD_DIR}/${SITE}/"
else
  # copy my-documents go.mod as a template if it exists
  cp "go.mod" "go.sum" "${BUILD_DIR}/${SITE}/"
fi

# Build site
(
  cd "${BUILD_DIR}/${SITE}"
  go get -u ./...
  go mod tidy
  hugo --minify
)
echo -e "${GREEN}✅ ${SITE} built successfully${NC}"
echo -e "  Output: ${BUILD_DIR}/${SITE}/public/"
