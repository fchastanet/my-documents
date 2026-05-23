#!/bin/bash
# Color definitions for bash scripts
# Source this file in other scripts: source "$(dirname "$0")/common.sh"

set -euo pipefail -o errexit

# ANSI color codes
COLOR_INFO='\033[0;34m'
COLOR_SUCCESS='\033[0;32m'
COLOR_WARNING='\033[0;33m'
COLOR_ERROR='\033[0;31m'
COLOR_RESET='\033[0m' # No Color

# Export for use in sub-shells
export COLOR_INFO COLOR_SUCCESS COLOR_WARNING COLOR_ERROR COLOR_RESET

# print the parent script name for better debugging
if [[ "${DEBUG:-0}" -eq 1 ]]; then
  if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo -e "${COLOR_WARNING}Sourcing common.sh from ${BASH_SOURCE[1]} $* ${COLOR_RESET}"
  fi
  set -x
fi
