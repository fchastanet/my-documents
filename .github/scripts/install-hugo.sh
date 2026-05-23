#!/bin/bash
# Install Hugo extended build
# Usage: ./install-hugo.sh [VERSION]

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

HUGO_VERSION="${1:-0.160.1}"

if command -v hugo >/dev/null 2>&1; then
  echo -e "${COLOR_SUCCESS}Hugo is already installed: $(hugo version)${COLOR_RESET}"
  exit 0
fi

echo -e "${COLOR_WARNING}Hugo not found. Installing version ${HUGO_VERSION}...${COLOR_RESET}"

CGO_ENABLED=1 go install -tags extended github.com/gohugoio/hugo@latest
