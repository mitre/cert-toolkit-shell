#!/bin/bash
set -euo pipefail

# Script Purpose:
# Checks and fixes file permissions for shell scripts and test files.
# Sets executable bit (755) on all relevant files while tracking changes.

# Key Features:
# - Cross-platform permission checking using ls -l
# - Accurate permission state detection
# - Color-coded output for status
# - Different icons for unchanged (✓) vs changed (➜) files
# - Debug mode for troubleshooting
# - Accurate counters using temp files to handle subshells
# - Directory-based organization with sorted output

# Best Practices Used:
# 1. Permission Checking:
#    - Uses ls -l instead of stat for better cross-platform compatibility
#    - Compares full permission string (-rwxr-xr-x) instead of octal
#
# 2. File Processing:
#    - Processes files directory by directory
#    - Uses find with -maxdepth to avoid recursive issues
#    - Handles filenames with spaces using null separation
#
# 3. Error Handling:
#    - Checks directory existence and readability
#    - Validates permission changes
#    - Counts and reports errors
#
# 4. State Management:
#    - Uses temp files to track counts across subshells
#    - Proper cleanup with trap
#    - Accurate change detection and reporting

# Colors for output
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

# Icons for status
CHECKMARK="✓"
CHANGED="➜"

# Debug mode
DEBUG=${DEBUG:-false}

# Error counter
errors=0

# Add counters at the top
files_checked=0
files_changed=0

# Use a temp file to store counts since we're in subshells
COUNTS_FILE=$(mktemp)
echo "0" >"$COUNTS_FILE"         # checked
echo "0" >"$COUNTS_FILE.changed" # changed

# Cleanup on exit
trap 'rm -f "$COUNTS_FILE" "$COUNTS_FILE.changed"' EXIT

debug() {
    if [[ "$DEBUG" == "true" ]]; then
        echo -e "${BLUE}DEBUG: $*${NC}" >&2
    fi
}

error() {
    ((errors++))
    echo -e "${RED}ERROR: $*${NC}" >&2
}

# Function to print directory contents
print_section() {
    local dir="$1"
    local title="$2"

    # Error handling for directory access
    if [ ! -d "$dir" ]; then
        debug "Directory not found: $dir"
        return 0
    fi

    if [ ! -r "$dir" ]; then
        error "Cannot read directory: $dir"
        return 1
    fi

    # Check if directory has any matching files
    if ! find "$dir" -maxdepth 1 -type f \( -name "*.bats" -o -name "*.sh" -o -name "*.bash" \) -print0 2>/dev/null | grep -q .; then
        debug "No matching files in: $dir"
        return 0
    fi

    echo -e "\n${BLUE}${title}:${NC}"
    find "$dir" -maxdepth 1 -type f \( -name "*.bats" -o -name "*.sh" -o -name "*.bash" \) -print0 2>/dev/null |
        while IFS= read -r -d '' file; do
            local name original_mode new_mode icon
            name=$(basename "$file")

            # Increment checked count
            echo $(($(cat "$COUNTS_FILE") + 1)) >"$COUNTS_FILE"

            # Get original permissions
            if ! original_mode=$(ls -l "$file" 2>/dev/null | awk '{print $1}'); then
                error "Cannot read permissions for: $file"
                continue
            fi

            if [[ "$original_mode" == "-rwxr-xr-x" ]]; then
                color=$GREEN
                icon=$CHECKMARK
                [[ "$DEBUG" == "true" ]] && debug "$name is already 755"
            else
                if ! chmod 755 "$file" 2>/dev/null; then
                    error "Failed to change permissions for: $file"
                    continue
                fi
                new_mode=$(ls -l "$file" | awk '{print $1}')
                color=$YELLOW
                icon=$CHANGED
                # Increment changed count
                echo $(($(cat "$COUNTS_FILE.changed") + 1)) >"$COUNTS_FILE.changed"
                debug "$name updated: $original_mode -> $new_mode"
            fi

            printf "${color}${icon}${NC} %-35s  ${color}755${NC}\n" "$name"
        done | sort
}

# Process directories in order
while IFS= read -r line; do
    dir=$(echo "$line" | cut -d: -f1)
    title=$(echo "$line" | cut -d: -f2)
    print_section "$dir" "$title"
done <<EOF
test/unit:Unit Tests
test/integration:Integration Tests
test/lib:Test Libraries
test/helper:Test Helpers
scripts:Scripts
test:Root Test Files
EOF

# Update final status to use counts from files
files_checked=$(cat "$COUNTS_FILE")
files_changed=$(cat "$COUNTS_FILE.changed")

# Display final status
if [ $errors -gt 0 ]; then
    echo -e "\n${RED}Completed with $errors errors${NC}"
    echo -e "Files checked: $files_checked"
    echo -e "Files changed: $files_changed"
    exit 1
else
    echo -e "\n${GREEN}All files verified!${NC}"
    echo -e "${BLUE}Files checked: ${GREEN}$files_checked${NC}"
    if [ $files_changed -gt 0 ]; then
        echo -e "${BLUE}Files changed: ${YELLOW}$files_changed${NC}"
    else
        echo -e "${BLUE}Files changed: ${GREEN}0${NC}"
    fi
fi
