#!/bin/bash
# Install Hugo extended build
# Usage: ./install-hugo.sh [VERSION]

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"
ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd -P)"

HUGO_VERSION="${1:-0.160.1}"

if [[ -f "${ROOT_DIR}/node_modules/.bin/postcss" ]]; then
  echo -e "${COLOR_INFO}Node dependencies are already installed.${COLOR_RESET}"
else
  echo -e "${COLOR_INFO}Installing node dependencies ...${COLOR_RESET}"
  (
    cd "${ROOT_DIR}" || exit 1
    npm ci
  )
fi

if command -v hugo >/dev/null 2>&1; then
  echo -e "${COLOR_SUCCESS}Hugo is already installed: $(hugo version)${COLOR_RESET}"
  exit 0
fi

echo -e "${COLOR_WARNING}Hugo not found. Installing version ${HUGO_VERSION}...${COLOR_RESET}"

CGO_ENABLED=1 go install -tags extended "github.com/gohugoio/hugo@${HUGO_VERSION}"
