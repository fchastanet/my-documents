#!/bin/bash
# Build Marp presentations to HTML and PPTX
# Usage: ./build-marp.sh [MARP_DIR] [OUTPUT_DIR]
# Example: ./build-marp.sh marp static/presentations

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

MARP_DIR="${1:-marp}"
OUTPUT_DIR="${2:-static/presentations}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$(dirname "${script_dir}")")"

echo -e "${BLUE}Building Marp presentations...${NC}"

# Verify marp directory exists
if [[ ! -d "${repo_root}/${MARP_DIR}" ]]; then
  echo -e "${YELLOW}⚠  ${MARP_DIR} directory not found. Skipping Marp build.${NC}"
  exit 0
fi

# Verify marp-cli is installed
if ! command -v marp &> /dev/null; then
  if [[ ! -f "${repo_root}/node_modules/.bin/marp" ]]; then
    echo -e "${YELLOW}⚠  Marp CLI not found. Run 'npm ci' first.${NC}"
    exit 1
  fi
  MARP_CMD="${repo_root}/node_modules/.bin/marp"
else
  MARP_CMD="marp"
fi

# Create output directory
mkdir -p "${repo_root}/${OUTPUT_DIR}"

# Change to repo root for marp execution
cd "${repo_root}" || exit 1

# Count presentations before processing
presentation_count=$(find "${MARP_DIR}" -name "*.md" -type f | wc -l)

if [[ "${presentation_count}" -eq 0 ]]; then
  echo -e "${YELLOW}  No Marp presentations found in ${MARP_DIR}${NC}"
  exit 0
fi

echo -e "${GREEN}Converting ${presentation_count} presentation(s)...${NC}"

# Generate HTML files (parallel processing via marp's -P flag)
echo -e "${BLUE}  Generating HTML files...${NC}"
"${MARP_CMD}" -I "${MARP_DIR}" -o "${OUTPUT_DIR}/" --html --allow-local-files 2>&1

# Generate PPTX files (parallel processing via marp's -P flag)
echo -e "${BLUE}  Generating PPTX files...${NC}"
"${MARP_CMD}" -I "${MARP_DIR}" -o "${OUTPUT_DIR}/" --pptx --allow-local-files 2>&1

# Verify outputs were created by checking each source file has corresponding outputs
missing_files=0
while IFS= read -r -d '' marp_file; do
  relative_path="${marp_file#"${MARP_DIR}/"}"
  base_name="$(basename "${relative_path}" .md)"
  dir_name="$(dirname "${relative_path}")"

  html_file="${OUTPUT_DIR}/${dir_name}/${base_name}.html"
  pptx_file="${OUTPUT_DIR}/${dir_name}/${base_name}.pptx"

  if [[ ! -f "${html_file}" ]]; then
    echo -e "${RED}  ❌ Missing HTML: ${html_file}${NC}"
    missing_files=$((missing_files + 1))
  fi

  if [[ ! -f "${pptx_file}" ]]; then
    echo -e "${RED}  ❌ Missing PPTX: ${pptx_file}${NC}"
    missing_files=$((missing_files + 1))
  fi
done < <(find "${MARP_DIR}" -name "*.md" -type f -print0)

if [[ "${missing_files}" -eq 0 ]]; then
  echo -e "${GREEN}✅ Successfully built ${presentation_count} presentation(s) (HTML + PPTX)${NC}"
else
  echo -e "${RED}❌ Build incomplete: ${missing_files} file(s) missing${NC}"
  exit 1
fi
