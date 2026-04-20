#!/bin/bash
# Install Hugo extended build
# Usage: ./install-hugo.sh [VERSION]

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

HUGO_VERSION="${1:-0.160.1}"

if command -v hugo >/dev/null 2>&1; then
  echo -e "${GREEN}Hugo is already installed: $(hugo version)${NC}"
  exit 0
fi

echo -e "${YELLOW}Hugo not found. Installing version ${HUGO_VERSION}...${NC}"

CGO_ENABLED=1 go install -tags extended github.com/gohugoio/hugo@latest
