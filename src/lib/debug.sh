#!/bin/bash

# Guard against multiple loading
if [[ -n "${DEBUG_LOADED:-}" ]]; then
    return 0
fi
declare -r DEBUG_LOADED=true

# Debug levels
declare -r DEBUG_LEVEL_ERROR=0
declare -r DEBUG_LEVEL_WARN=1
declare -r DEBUG_LEVEL_INFO=2
declare -r DEBUG_LEVEL_DEBUG=3
declare -r DEBUG_LEVEL_TRACE=4

# Default debug level
DEBUG_LEVEL=$DEBUG_LEVEL_INFO

# Debug log file
DEBUG_LOG_FILE=""

# Initialize debug system
init_debug() {
    local log_file="${1:-}"
    local debug_level="${2:-$DEBUG_LEVEL_INFO}"

    DEBUG_LEVEL=$debug_level
    [[ -n "$log_file" ]] && DEBUG_LOG_FILE="$log_file"

    # Create log file if specified
    if [[ -n "$DEBUG_LOG_FILE" ]]; then
        : >"$DEBUG_LOG_FILE" || {
            echo -e "${FAIL}Failed to create debug log file${RSET}" >&2
            return 1
        }
    fi

    return 0
}

# Internal logging function
_log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Format the message
    local formatted_message="[$timestamp] [$level] $message"

    # Log to file if configured
    if [[ -n "$DEBUG_LOG_FILE" ]]; then
        echo "$formatted_message" >>"$DEBUG_LOG_FILE"
    fi

    # Return if we shouldn't display this level
    case "$level" in
    ERROR) [[ $DEBUG_LEVEL -lt $DEBUG_LEVEL_ERROR ]] && return ;;
    WARN) [[ $DEBUG_LEVEL -lt $DEBUG_LEVEL_WARN ]] && return ;;
    INFO) [[ $DEBUG_LEVEL -lt $DEBUG_LEVEL_INFO ]] && return ;;
    DEBUG) [[ $DEBUG_LEVEL -lt $DEBUG_LEVEL_DEBUG ]] && return ;;
    TRACE) [[ $DEBUG_LEVEL -lt $DEBUG_LEVEL_TRACE ]] && return ;;
    esac

    # Display to console with color
    case "$level" in
    ERROR) echo -e "${FAIL}${formatted_message}${RSET}" >&2 ;;
    WARN) echo -e "${WARN}${formatted_message}${RSET}" >&2 ;;
    INFO) echo -e "${HIGH}${formatted_message}${RSET}" ;;
    DEBUG) echo -e "${VERB}${formatted_message}${RSET}" ;;
    TRACE) echo -e "${VERB}${formatted_message}${RSET}" ;;
    esac
}

# Public logging functions
error() {
    _log "ERROR" "$1"
    if [[ "${DEBUG:-false}" == "true" ]]; then
        # Show stack trace in debug mode
        local frame=0
        while caller $frame; do
            ((frame++))
        done >&2
    fi
}
warn() { _log "WARN" "$1"; }
info() { _log "INFO" "$1"; }
debug() { _log "DEBUG" "$1"; }
trace() { _log "TRACE" "$1"; }

# Debug metrics
debug_metrics() {
    local location="$1"

    [[ $DEBUG_LEVEL -lt $DEBUG_LEVEL_DEBUG ]] && return

    debug "=== Metrics at $location ==="
    debug "Total certificates: $(get_metric "" "total")"
    debug "PEM certificates:  $(get_metric "" "pem")"
    debug "DER certificates:  $(get_metric "" "der")"
    debug "PKCS7 certificates:$(get_metric "" "pkcs7")"
    debug "Failed:           $(get_metric "" "failed")"
    debug "Skipped:          $(get_metric "" "skipped")"

    # Print bundle metrics
    for bundle in dod org ca; do
        local processed=$(get_metric "$bundle" "processed")
        local failed=$(get_metric "$bundle" "failed")
        local skipped=$(get_metric "$bundle" "skipped")
        debug "${bundle^^} Bundle: processed=$processed failed=$failed skipped=$skipped"
    done
    debug "=== End Metrics ==="
}

# Certificate debug info
debug_certificate() {
    local cert_file="$1"
    local message="${2:-Certificate debug info}"

    [[ $DEBUG_LEVEL -lt $DEBUG_LEVEL_DEBUG ]] && return

    debug "$message:"
    debug "  File: $cert_file"
    debug "  Size: $(wc -c <"$cert_file") bytes"

    if command -v file >/dev/null 2>&1; then
        debug "  Type: $(file "$cert_file")"
    fi

    # Show certificate details if it's valid
    if openssl x509 -noout -text -in "$cert_file" &>/dev/null; then
        local subject issuer dates
        subject=$(openssl x509 -noout -subject -in "$cert_file" 2>/dev/null)
        issuer=$(openssl x509 -noout -issuer -in "$cert_file" 2>/dev/null)
        dates=$(openssl x509 -noout -dates -in "$cert_file" 2>/dev/null)

        debug "  Subject: $subject"
        debug "  Issuer:  $issuer"
        debug "  Dates:   $dates"
    fi
}

# Set debug level from string
set_debug_level() {
    local level="${1,,}" # Convert to lowercase

    case "$level" in
    error) DEBUG_LEVEL=$DEBUG_LEVEL_ERROR ;;
    warn) DEBUG_LEVEL=$DEBUG_LEVEL_WARN ;;
    info) DEBUG_LEVEL=$DEBUG_LEVEL_INFO ;;
    debug) DEBUG_LEVEL=$DEBUG_LEVEL_DEBUG ;;
    trace) DEBUG_LEVEL=$DEBUG_LEVEL_TRACE ;;
    *) return 1 ;;
    esac

    return 0
}
