#!/bin/bash
# Install Hugo extended build
# Usage: ./install-hugo.sh [VERSION]

source "$(dirname "$0")/common.sh"

HUGO_VERSION="${1:-0.155.3}"

if command -v hugo >/dev/null 2>&1; then
  echo -e "${GREEN}Hugo is already installed: $(hugo version)${NC}"
  exit 0
fi

echo -e "${YELLOW}Hugo not found. Installing version ${HUGO_VERSION}...${NC}"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')

if [ "$OS" = "linux" ]; then
  FILENAME="hugo_extended_${HUGO_VERSION}_${OS}-${ARCH}.deb"
  URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${FILENAME}"

  echo -e "${BLUE}Downloading ${URL}${NC}"
  curl -L -o "/tmp/${FILENAME}" "$URL"

  echo -e "${BLUE}Installing ${FILENAME}${NC}"
  sudo dpkg -i "/tmp/${FILENAME}"
  rm "/tmp/${FILENAME}"

  echo -e "${GREEN}Hugo installed: $(hugo version)${NC}"
else
  echo -e "${RED}Unsupported OS: ${OS}${NC}"
  echo "Please install Hugo manually from https://gohugo.io/installation/"
  exit 1
fi
