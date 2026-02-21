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

# Export for use in subshells
export BLUE GREEN YELLOW RED NC
