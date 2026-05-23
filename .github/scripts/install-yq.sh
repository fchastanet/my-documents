#!/bin/bash
# Install yq YAML processor
# Usage: ./install-yq.sh

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

if command -v yq >/dev/null 2>&1; then
  echo -e "${COLOR_SUCCESS}yq is already installed: $(yq --version)${COLOR_RESET}"
  exit 0
fi

echo -e "${COLOR_WARNING}yq not found. Installing...${COLOR_RESET}"

sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

echo -e "${COLOR_SUCCESS}yq installed: $(yq --version)${COLOR_RESET}"
