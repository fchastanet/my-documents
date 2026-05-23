#!/bin/bash
# Copy shared resources (layouts, assets, archetypes) to build directory
# Usage: ./copy-shared-resources.sh SOURCE_DIR TARGET_DIR
# Example: ./copy-shared-resources.sh orchestrator/shared build/bash-compiler

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

SOURCE_DIR="${1:?Error: SOURCE_DIR argument required}"
TARGET_DIR="${2:?Error: TARGET_DIR argument required}"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo -e "${COLOR_ERROR}✗ Source directory not found: ${SOURCE_DIR}${COLOR_RESET}"
  exit 1
fi

mkdir -p "${TARGET_DIR}"

echo -e "${COLOR_INFO}Copying shared resources from ${SOURCE_DIR}...${COLOR_RESET}"
cp -r "${SOURCE_DIR}"/* "${TARGET_DIR}/"

echo -e "${COLOR_SUCCESS}✅ Shared resources copied${COLOR_RESET}"
