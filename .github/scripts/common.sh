#!/bin/bash
# Color definitions for bash scripts
# Source this file in other scripts: source "$(dirname "$0")/common.sh"

set -euo pipefail -o errexit

# ANSI color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Export for use in sub-shells
export BLUE GREEN YELLOW RED NC

# print the parent script name for better debugging
if [[ "${DEBUG:-0}" -eq 1 ]]; then
  if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo -e "${YELLOW}Sourcing common.sh from ${BASH_SOURCE[1]} $* ${NC}"
  fi
  set -x
fi
