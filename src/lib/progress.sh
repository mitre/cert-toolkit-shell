#!/bin/bash

# Guard against multiple loading
if [[ -n "${PROGRESS_LOADED:-}" ]]; then
    return 0
fi
declare -r PROGRESS_LOADED=true

# Progress indicator states
declare -i PROGRESS_TOTAL=0
declare -i PROGRESS_CURRENT=0
declare PROGRESS_MESSAGE=""

# Initialize progress tracking
init_progress() {
    local total="$1"
    local message="${2:-Processing}"
    PROGRESS_TOTAL=$total
    PROGRESS_CURRENT=0
    PROGRESS_MESSAGE="$message"
}

# Update progress
update_progress() {
    local increment="${1:-1}"
    PROGRESS_CURRENT=$((PROGRESS_CURRENT + increment))

    # Only show progress if not in quiet mode
    if [[ "$(get_config QUIET)" != "true" ]]; then
        local percent=$((PROGRESS_CURRENT * 100 / PROGRESS_TOTAL))
        printf "\r%s: [%-50s] %d%%" "$PROGRESS_MESSAGE" \
            "$(printf '#%.0s' $(seq 1 $((percent / 2))))" "$percent"
        [[ $PROGRESS_CURRENT -eq $PROGRESS_TOTAL ]] && echo
    fi
}
