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

if [ ! -f "$BASE_CONFIG" ]; then
  echo -e "${RED}✗ Base config not found: $BASE_CONFIG${NC}"
  exit 1
fi

if [ ! -f "$SITE_CONFIG" ]; then
  echo -e "${RED}✗ Site config not found: $SITE_CONFIG${NC}"
  exit 1
fi

echo -e "${BLUE}Merging configs...${NC}"
echo -e "  Base: $BASE_CONFIG"
echo -e "  Site: $SITE_CONFIG"
echo -e "  Output: $OUTPUT_FILE"

# Merge configs using yq (proper YAML deep merge)
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
  "$BASE_CONFIG" "$SITE_CONFIG" > "$OUTPUT_FILE"

# Override baseURL if provided
if [ -n "$BASE_URL" ]; then
  echo -e "  Setting baseURL to: $BASE_URL"
  yq eval -i ".baseURL = \"$BASE_URL\"" "$OUTPUT_FILE"
fi

echo -e "${GREEN}✅ Configs merged${NC}"
