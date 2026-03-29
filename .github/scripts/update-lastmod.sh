#!/bin/bash
# Update date and lastmod frontmatter fields in markdown files
# Usage:
#   ./update-lastmod.sh                    # Migration mode: update all files in content/
#   ./update-lastmod.sh file1.md file2.md  # Commit mode: update specific files

# shellcheck source=.github/scripts/common.sh
source "$(dirname "$0")/common.sh"

# Configuration
readonly CONTENT_DIR="content"
readonly TIMEZONE="Europe/Paris"
readonly DEFAULT_TIME="08:00:00"
readonly DATE_FORMAT="%Y-%m-%dT%H:%M:%S%:z"

# Get current date in the required format
getCurrentDate() {
  TZ="$TIMEZONE" date +"$DATE_FORMAT"
}

# Get today's date (YYYY-MM-DD only)
getTodayDate() {
  TZ="$TIMEZONE" date +"%Y-%m-%d"
}

# Extract date portion from ISO8601 timestamp
# Args: $1 = timestamp (e.g., "2026-03-29T15:30:05+02:00")
getDatePortion() {
  local timestamp="$1"
  # Extract YYYY-MM-DD portion
  echo "$timestamp" | sed 's/T.*//; s/["'\'']*//g'
}

# Get git creation date for a file
# Args: $1 = file path
getGitCreationDate() {
  local file="$1"
  local timestamp

  # Get the first commit date for this file
  timestamp=$(git log --follow --format="%aI" --reverse -- "$file" | head -1)

  if [[ -z "$timestamp" ]]; then
    # File not in git yet, use current date with default time
    getCurrentDate
    return
  fi

  # Convert to our format with default time if no time component
  local dateOnly
  dateOnly=$(date -d "$timestamp" +"%Y-%m-%d" 2>/dev/null || echo "")

  if [[ -z "$dateOnly" ]]; then
    getCurrentDate
    return
  fi

  # Format with default time and timezone
  TZ="$TIMEZONE" date -d "$dateOnly $DEFAULT_TIME" +"$DATE_FORMAT"
}

# Get git last modification date for a file
# Args: $1 = file path
getGitModificationDate() {
  local file="$1"
  local timestamp

  # Get the last commit date for this file
  timestamp=$(git log --follow --format="%aI" -1 -- "$file" | head -1)

  if [[ -z "$timestamp" ]]; then
    # File not in git yet, use current date with default time
    getCurrentDate
    return
  fi

  # Convert to our format with default time if no time component
  local dateOnly
  dateOnly=$(date -d "$timestamp" +"%Y-%m-%d" 2>/dev/null || echo "")

  if [[ -z "$dateOnly" ]]; then
    getCurrentDate
    return
  fi

  # Format with default time and timezone
  TZ="$TIMEZONE" date -d "$dateOnly $DEFAULT_TIME" +"$DATE_FORMAT"
}

# Extract frontmatter from markdown file
# Args: $1 = file path
extractFrontmatter() {
  local file="$1"

  # Extract content between first two ---
  awk '/^---$/ {if (++count == 2) exit} count == 1 && NR > 1' "$file"
}

# Get the line number where frontmatter ends
# Args: $1 = file path
getFrontmatterEndLine() {
  local file="$1"

  # Find the line number of the second ---
  awk '/^---$/ {count++; if (count == 2) {print NR; exit}}' "$file"
}

# Check if frontmatter has a field
# Args: $1 = frontmatter content, $2 = field name
hasFrontmatterField() {
  local frontmatter="$1"
  local field="$2"

  echo "$frontmatter" | grep -q "^${field}:"
}

# Get frontmatter field value
# Args: $1 = frontmatter content, $2 = field name
getFrontmatterField() {
  local frontmatter="$1"
  local field="$2"

  echo "$frontmatter" | grep "^${field}:" | sed "s/^${field}: *//; s/['\"]//g" | head -1
}

# Increment version number
# Args: $1 = version string (e.g., "1.2" or "1.2.3")
incrementVersion() {
  local version="$1"

  # Extract the last number and increment it
  if [[ "$version" =~ ^([0-9]+)\.([0-9]+)(\.([0-9]+))?$ ]]; then
    local major="${BASH_REMATCH[1]}"
    local minor="${BASH_REMATCH[2]}"
    local patch="${BASH_REMATCH[4]}"

    if [[ -n "$patch" ]]; then
      # Has patch version, increment it
      echo "${major}.${minor}.$((patch + 1))"
    else
      # Only major.minor, increment minor
      echo "${major}.$((minor + 1))"
    fi
  else
    # Invalid format, return as is
    echo "$version"
  fi
}

# Update frontmatter in a markdown file
# Args: $1 = file path, $2 = frontmatter content
updateFrontmatter() {
  local file="$1"
  local newFrontmatter="$2"
  local endLine

  endLine=$(getFrontmatterEndLine "$file")

  if [[ -z "$endLine" ]]; then
    echo -e "${RED}✗ No frontmatter found in $file${NC}"
    return 1
  fi

  # Create temp file with new frontmatter and remaining content
  {
    echo "---"
    echo "$newFrontmatter"
    echo "---"
    tail -n +"$((endLine + 1))" "$file"
  } >"${file}.tmp"

  mv "${file}.tmp" "$file"
}

# Process a file in migration mode (migrate old fields to new ones)
# Args: $1 = file path
processMigrationMode() {
  local file="$1"
  local frontmatter
  local newFrontmatter
  local dateValue=""
  local lastmodValue=""
  local modified=0

  echo -e "${BLUE}Processing migration: $file${NC}"

  # Extract current frontmatter
  frontmatter=$(extractFrontmatter "$file")

  if [[ -z "$frontmatter" ]]; then
    echo -e "${YELLOW}  ⊘ No frontmatter found, skipping${NC}"
    return 0
  fi

  # Remove old field names first
  newFrontmatter=$(echo "$frontmatter" | grep -v "^creationDate:" | grep -v "^lastUpdated:")

  # Handle date field
  if ! hasFrontmatterField "$frontmatter" "date"; then
    if hasFrontmatterField "$frontmatter" "creationDate"; then
      # Migrate from creationDate
      dateValue=$(getFrontmatterField "$frontmatter" "creationDate")

      # Convert date to proper format with time if needed
      if [[ ! "$dateValue" =~ T ]]; then
        # Add default time and timezone
        dateValue=$(TZ="$TIMEZONE" date -d "$dateValue $DEFAULT_TIME" +"$DATE_FORMAT")
      fi

      echo -e "${GREEN}  ✓ Migrating creationDate to date: $dateValue${NC}"
      modified=1
    else
      # Get from git
      dateValue=$(getGitCreationDate "$file")
      echo -e "${GREEN}  ✓ Creating date from git: $dateValue${NC}"
      modified=1
    fi
  fi

  # Handle lastmod field
  if ! hasFrontmatterField "$frontmatter" "lastmod"; then
    if hasFrontmatterField "$frontmatter" "lastUpdated"; then
      # Migrate from lastUpdated
      lastmodValue=$(getFrontmatterField "$frontmatter" "lastUpdated")

      # Convert date to proper format with time if needed
      if [[ ! "$lastmodValue" =~ T ]]; then
        # Add default time and timezone
        lastmodValue=$(TZ="$TIMEZONE" date -d "$lastmodValue $DEFAULT_TIME" +"$DATE_FORMAT")
      fi

      echo -e "${GREEN}  ✓ Migrating lastUpdated to lastmod: $lastmodValue${NC}"
      modified=1
    else
      # Get from git
      lastmodValue=$(getGitModificationDate "$file")
      echo -e "${GREEN}  ✓ Creating lastmod from git: $lastmodValue${NC}"
      modified=1
    fi
  fi

  # Handle version field
  if ! hasFrontmatterField "$newFrontmatter" "version"; then
    echo -e "${GREEN}  ✓ Adding version: 1.0${NC}"
    modified=1
  fi

  # Add date, lastmod, and version at the end of frontmatter
  if [[ $modified -eq 1 ]]; then
    # Append date if we have a value
    if [[ -n "$dateValue" ]]; then
      newFrontmatter=$(printf "%s\ndate: '%s'" "$newFrontmatter" "$dateValue")
    fi

    # Append lastmod if we have a value
    if [[ -n "$lastmodValue" ]]; then
      newFrontmatter=$(printf "%s\nlastmod: '%s'" "$newFrontmatter" "$lastmodValue")
    fi

    # Append version if it doesn't exist
    if ! hasFrontmatterField "$frontmatter" "version"; then
      newFrontmatter=$(printf "%s\nversion: '1.0'" "$newFrontmatter")
    fi
  fi

  # Update file if modified
  if [[ $modified -eq 1 ]]; then
    updateFrontmatter "$file" "$newFrontmatter"
    echo -e "${GREEN}  ✅ Updated $file${NC}"
  else
    echo -e "${YELLOW}  ⊘ No changes needed${NC}"
  fi
}

# Process a file in commit mode (set current date if fields missing)
# Args: $1 = file path
processCommitMode() {
  local file="$1"
  local frontmatter
  local newFrontmatter
  local currentDate
  local modified=0

  echo -e "${BLUE}Processing commit: $file${NC}"

  # Only process .md files in content directory
  if [[ ! "$file" =~ ^content/.*\.md$ ]]; then
    echo -e "${YELLOW}  ⊘ Not a content markdown file, skipping${NC}"
    return 0
  fi

  # Check if file exists
  if [[ ! -f "$file" ]]; then
    echo -e "${YELLOW}  ⊘ File not found, skipping${NC}"
    return 0
  fi

  # Extract current frontmatter
  frontmatter=$(extractFrontmatter "$file")

  if [[ -z "$frontmatter" ]]; then
    echo -e "${YELLOW}  ⊘ No frontmatter found, skipping${NC}"
    return 0
  fi

  currentDate=$(getCurrentDate)
  local todayDate
  todayDate=$(getTodayDate)

  # Check if lastmod already has today's date
  local skipUpdate=0
  if hasFrontmatterField "$frontmatter" "lastmod"; then
    local existingLastmod
    existingLastmod=$(getFrontmatterField "$frontmatter" "lastmod")
    local existingDate
    existingDate=$(getDatePortion "$existingLastmod")

    if [[ "$existingDate" == "$todayDate" ]]; then
      echo -e "${YELLOW}  ⊘ Already updated today, skipping lastmod and version${NC}"
      skipUpdate=1
    fi
  fi

  # Remove date, lastmod, and version fields from frontmatter (we'll add them at the end)
  newFrontmatter=$(echo "$frontmatter" | grep -v "^date:" | grep -v "^lastmod:" | grep -v "^version:")

  # Determine date value
  local dateValue
  if hasFrontmatterField "$frontmatter" "date"; then
    dateValue=$(getFrontmatterField "$frontmatter" "date")
  else
    dateValue="$currentDate"
    echo -e "${GREEN}  ✓ Adding date: $currentDate${NC}"
    modified=1
  fi

  # Update lastmod only if not already updated today
  local lastmodValue
  if [[ $skipUpdate -eq 1 ]]; then
    # Keep existing lastmod
    lastmodValue=$(getFrontmatterField "$frontmatter" "lastmod")
  else
    # Update to current date
    lastmodValue="$currentDate"
    echo -e "${GREEN}  ✓ Updating lastmod: $currentDate${NC}"
    modified=1
  fi

  # Handle version increment
  local versionValue
  if [[ $skipUpdate -eq 1 ]]; then
    # Keep existing version
    if hasFrontmatterField "$frontmatter" "version"; then
      versionValue=$(getFrontmatterField "$frontmatter" "version")
    else
      versionValue="1.0"
    fi
  elif hasFrontmatterField "$frontmatter" "version"; then
    local oldVersion
    oldVersion=$(getFrontmatterField "$frontmatter" "version")
    versionValue=$(incrementVersion "$oldVersion")
    echo -e "${GREEN}  ✓ Incrementing version: $oldVersion → $versionValue${NC}"
    modified=1
  else
    versionValue="1.0"
    echo -e "${GREEN}  ✓ Adding version: $versionValue${NC}"
    modified=1
  fi

  # Add date, lastmod, and version at the end of frontmatter
  newFrontmatter=$(printf "%s\ndate: '%s'\nlastmod: '%s'\nversion: '%s'" "$newFrontmatter" "$dateValue" "$lastmodValue" "$versionValue")

  # Update file if modified
  if [[ $modified -eq 1 ]]; then
    updateFrontmatter "$file" "$newFrontmatter"
    echo -e "${GREEN}  ✅ Updated $file${NC}"
  else
    echo -e "${YELLOW}  ⊘ No changes needed${NC}"
  fi
}

# Main function
main() {
  if [[ $# -eq 0 ]]; then
    # Migration mode: process all .md files in content/
    echo -e "${BLUE}Running in migration mode: updating all files in $CONTENT_DIR/${NC}"

    local fileCount=0
    while IFS= read -r -d '' file; do
      processMigrationMode "$file"
      fileCount=$((fileCount + 1))
    done < <(find "$CONTENT_DIR" -type f -name "*.md" -print0)

    echo -e "${GREEN}✅ Migration complete: processed $fileCount files${NC}"
  else
    # Commit mode: process specific files
    echo -e "${BLUE}Running in commit mode: updating ${#@} file(s)${NC}"

    for file in "$@"; do
      processCommitMode "$file"
    done

    echo -e "${GREEN}✅ Commit mode complete${NC}"
  fi
}

# Run main function
main "$@"
