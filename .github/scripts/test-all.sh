#!/bin/bash
# Test all built sites with curl
# Usage: ./test-all.sh [BUILD_DIR] [SITES_DIR] [REPOS...]
# Example: ./test-all.sh build sites bash-compiler bash-tools bash-tools-framework bash-dev-env

source "$(dirname "$0")/common.sh"

BUILD_DIR="${1:-build}"
SITES_DIR="${2:-sites}"
shift 2 || true
REPOS=("$@")

if [ ${#REPOS[@]} -eq 0 ]; then
  echo -e "${YELLOW}No repositories specified${NC}"
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$(dirname "$script_dir")")"

cd "$repo_root"

echo -e "${BLUE}Testing all sites with curl...${NC}"

# Test my-documents
(
  echo "  Testing my-documents..."
  hugo server -D --port 1313 > /dev/null 2>&1 &
  SERVER_PID=$!
  trap '(kill $SERVER_PID 2>/dev/null; sleep 1) || true' EXIT
  sleep 2

  if curl -s -o /dev/null -w "%{http_code}" http://localhost:1313/my-documents/ | grep -q "200"; then
    echo -e "    ${GREEN}✓${NC} my-documents: http://localhost:1313/my-documents/"
  else
    echo -e "    ${YELLOW}✗${NC} my-documents failed"
  fi
)
# Test other sites

for repo in "${REPOS[@]}"; do
  if [ -d "${BUILD_DIR}/${repo}/public" ]; then
    (
      echo "  Testing ${repo}..."
      trap '(kill $SERVER_PID 2>/dev/null; sleep 1) || true' EXIT
      hugo server -D --source "${SITES_DIR}/${repo}" --port 1314 > /dev/null 2>&1 &
      SERVER_PID=$!
      sleep 2

      if curl -s -o /dev/null -w "%{http_code}" "http://localhost:1314/${repo}/" | grep -q "200"; then
        echo -e "    ${GREEN}✓${NC} ${repo}: http://localhost:1314/${repo}/"
      else
        echo -e "    ${YELLOW}✗${NC} ${repo} failed"
      fi
    )
  fi
done

echo -e "${GREEN}✅ All tests complete${NC}"
