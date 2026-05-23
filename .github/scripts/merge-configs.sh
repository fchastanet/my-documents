#!/bin/bash
# Merge base config with site-specific config using yq
# Usage: ./merge-configs.sh BASE_CONFIG SITE_CONFIG OUTPUT_FILE [BASE_URL]
# Example: ./merge-configs.sh configs/_base.yaml configs/bash-compiler.yaml build/bash-compiler/hugo.yaml

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

BASE_CONFIG="${1:?Error: BASE_CONFIG argument required}"
SITE_CONFIG="${2:?Error: SITE_CONFIG argument required}"
OUTPUT_FILE="${3:?Error: OUTPUT_FILE argument required}"
BASE_URL="${4:-}"

if [[ ! -f "${BASE_CONFIG}" ]]; then
  echo -e "${COLOR_ERROR}❌ Base config not found: ${BASE_CONFIG}${COLOR_RESET}"
  exit 1
fi

if [[ ! -f "${SITE_CONFIG}" ]]; then
  echo -e "${COLOR_ERROR}❌ Site config not found: ${SITE_CONFIG}${COLOR_RESET}"
  exit 1
fi

echo -e "${COLOR_INFO}Merging configs...${COLOR_RESET}"
echo -e "  Base: ${BASE_CONFIG}"
echo -e "  Site: ${SITE_CONFIG}"
echo -e "  Output: ${OUTPUT_FILE}"

# Merge configs using yq (proper YAML deep merge)
# shellcheck disable=SC2016
yq eval-all '. as $item ireduce ({}; . *+ $item)' \
  "${BASE_CONFIG}" "${SITE_CONFIG}" > "${OUTPUT_FILE}"

# Override baseURL if provided
if [[ -n "${BASE_URL}" ]]; then
  echo -e "  Setting baseURL to: ${BASE_URL}"
  yq eval -i ".baseURL = \"${BASE_URL}\"" "${OUTPUT_FILE}"
fi

echo -e "${COLOR_SUCCESS}✅ Configs merged${COLOR_RESET}"
