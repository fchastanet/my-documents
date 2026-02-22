#!/bin/bash
# Install yq YAML processor
# Usage: ./install-yq.sh

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

if command -v yq >/dev/null 2>&1; then
  echo -e "${GREEN}yq is already installed: $(yq --version)${NC}"
  exit 0
fi

echo -e "${YELLOW}yq not found. Installing...${NC}"

sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

echo -e "${GREEN}yq installed: $(yq --version)${NC}"
