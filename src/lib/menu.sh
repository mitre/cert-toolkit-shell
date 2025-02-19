#!/bin/bash

# Guard against multiple loading
if [[ -n "${MENU_LOADED:-}" ]]; then
    return 0
fi
declare -r MENU_LOADED=true

# Command definitions with long/short forms
declare -A COMMANDS=(
    [process]="Process certificates"
    [verify]="Verify certificate"
    [info]="Show certificate information"
    [config]="Show or update configuration"
    [help]="Show help information"
    [version]="Show version information"
)

# Standard flag definitions (GNU compliance)
declare -A STANDARD_FLAGS=(
    # GNU standard order
    [--help | -h]="Display help text"       # Help always first
    [--version | -V]="Display version info" # Version always second
    [--verbose | -v]="Show detailed output" # Output controls
    [--quiet | -q]="Suppress normal output" # Output controls
    [--debug | -d]="Enable debug mode"      # Special modes last
)

# Command-specific flag definitions
declare -A PROCESS_FLAGS=(
    [--ca - skip]="Skip processing ca-certificates.crt"
    [--dod - skip]="Skip processing DoD certificates"
    [--org - skip]="Skip processing organization certificates"
    [--pem - file]="Process organization certificates from combined PEM file"
    [--individual]="Process individual certificates"
    [--fetch - dynamic]="Fetch certificate list dynamically"
    [--skip - update]="Skip updating CA certificates store"
    [--log - file]="Enable logging to specified file"
)

# Show main help (GNU/POSIX compliant)
show_help() {
    # Program name and brief (POSIX)
    echo -e "${HIGH}NAME${RSET}"
    echo "    ${SCRIPT_NAME} - ${DESCRIPTION}"

    # Synopsis (POSIX)
    echo -e "\n${HIGH}SYNOPSIS${RSET}"
    echo "    ${SCRIPT_NAME} [OPTIONS] COMMAND [ARGS]"

    # Description (GNU)
    echo -e "\n${HIGH}DESCRIPTION${RSET}"
    echo "    Certificate management tool for Linux systems."

    # Options (GNU style)
    echo -e "\n${HIGH}OPTIONS${RSET}"
    for flag in "${!STANDARD_FLAGS[@]}"; do
        printf "    %-20s %s\n" "$flag" "${STANDARD_FLAGS[$flag]}"
    done

    # Commands (CLIG style)
    echo -e "\n${HIGH}COMMANDS${RSET}"
    for cmd in "${!COMMANDS[@]}"; do
        printf "    %-20s %s\n" "$cmd" "${COMMANDS[$cmd]}"
    done

    # Exit status (GNU)
    echo -e "\n${HIGH}EXIT STATUS${RSET}"
    echo "    0    Success"
    echo "    1    General error"
    echo "    2    Invalid usage"

    # Examples (CLIG)
    echo -e "\n${HIGH}EXAMPLES${RSET}"
    echo "    ${SCRIPT_NAME} config --list"
    echo "    ${SCRIPT_NAME} process --ca-skip"
}

# Show command-specific help
show_command_help() {
    local command="$1"
    case "$command" in
    process)
        echo -e "${VERB}Usage: ${0##*/} process [options]${RSET}"
        echo -e "\n${HIGH}Options:${RSET}"
        for flag in "${!PROCESS_FLAGS[@]}"; do
            printf "  %-20s  %s\n" "$flag" "${PROCESS_FLAGS[$flag]}"
        done
        ;;
    verify)
        echo -e "${VERB}Usage: ${0##*/} verify <certificate-file> [options]${RSET}"
        echo -e "\n${HIGH}Options:${RSET}"
        echo "  --debug, -d     Enable debug output"
        echo "  --verbose       Show detailed validation"
        ;;
    info)
        echo -e "${VERB}Usage: ${0##*/} info <certificate-file> [options]${RSET}"
        echo -e "\n${HIGH}Options:${RSET}"
        echo "  -s              Show subject only"
        echo "  -i              Show issuer only"
        echo "  -d              Show dates only"
        echo "  -a              Show all information (default)"
        ;;
    config)
        echo -e "${VERB}Usage: ${0##*/} config [options]${RSET}"
        echo -e "\n${HIGH}Options:${RSET}"
        echo "  --list, -l              List current configuration"
        echo "  --verbose               Show detailed configuration"
        echo "  --set KEY=VALUE         Set configuration value"
        echo "  --help                  Show this help message"
        ;;
    *)
        error "Unknown command: $command"
        show_help
        return 1
        ;;
    esac

    # Show global options for all commands
    echo -e "\n${HIGH}Global Options:${RSET}"
    for flag in "${!STANDARD_FLAGS[@]}"; do
        printf "  %-20s  %s\n" "$flag" "${STANDARD_FLAGS[$flag]}"
    done
}

# Show error messages (GNU format)
error() {
    echo -e "${FAIL}${SCRIPT_NAME}: error: ${1}${RSET}" >&2
    echo "Try '${SCRIPT_NAME} --help' for more information." >&2
}

# Command error messages (GNU format)
command_error() {
    local cmd="$1"
    local msg="$2"
    echo -e "${FAIL}${SCRIPT_NAME}: $cmd: ${msg}${RSET}" >&2
    echo "Try '${SCRIPT_NAME} $cmd --help' for more information." >&2
}

# Parse command line arguments
parse_args() {
    local command="process" # Default command
    local args=()

    # First argument might be a command
    if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
        command="$1"
        shift
    fi

    # Validate command exists
    if ! declare -F "cmd_$command" >/dev/null; then
        error "Unknown command: $command"
        show_help
        return 1
    fi

    # Show help without requiring initialization
    if [[ "$command" == "help" ]]; then
        [[ $# -gt 0 ]] && show_command_help "$1" || show_help
        return 0
    fi

    # Process global options first
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --*=*)
            local key="${1%%=*}"
            local value="${1#*=}"
            args+=("$key" "$value")
            shift
            ;;
        --* | -*)
            args+=("$1")
            shift
            ;;
        *)
            break
            ;;
        esac
    done

    # Execute command with parsed arguments
    "cmd_$command" "${args[@]:-}"
    return $?
}

# Command implementations
cmd_process() {
    debug "Processing certificates with args: $*"
    process_certificates "$@"
}

cmd_verify() {
    if [[ "$1" == "--help" ]]; then
        show_command_help "verify"
        return 0
    fi

    local cert_file="$1"
    debug "Verifying certificate: $cert_file"
    validate_certificate "$cert_file" "verify" true
}

cmd_info() {
    if [[ "$1" == "--help" ]]; then
        show_command_help "info"
        return 0
    fi

    local cert_file="$1"
    shift
    local info_type="all"

    while getopts ":sida" opt; do
        case $opt in
        s) info_type="subject" ;;
        i) info_type="issuer" ;;
        d) info_type="dates" ;;
        a) info_type="all" ;;
        *)
            error "Invalid option: -$OPTARG"
            return 1
            ;;
        esac
    done

    if [[ -f "$cert_file" ]]; then
        get_cert_info "$cert_file" "$info_type"
    else
        error "Certificate file not found: $cert_file"
        return 1
    fi
}

cmd_config() {
    if [[ "$1" == "--help" ]]; then
        show_command_help "config"
        return 0
    fi

    local verbose=false
    local show_config=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --list | -l)
            show_config=true
            shift
            ;;
        --verbose | -v)
            verbose=true
            shift
            ;;
        --set)
            shift
            if [[ -z "${1:-}" ]] || [[ ! "$1" =~ = ]]; then
                error "Option --set requires KEY=VALUE argument"
                show_command_help "config"
                return "$EXIT_INVALID_USAGE"
            fi
            local key="${1%%=*}"
            # Don't allow setting debug via --set
            if [[ "$key" == "DEBUG" ]]; then
                error "DEBUG can only be set via environment or --debug flag"
                return "$EXIT_INVALID_USAGE"
            fi
            local value="${1#*=}"
            debug "Setting config: $key=$value"
            if ! set_config "$key" "$value"; then
                show_command_help "config"
                return "$EXIT_INVALID_USAGE"
            fi
            shift
            ;;
        *)
            error "Invalid option: $1"
            show_command_help "config"
            return "$EXIT_INVALID_USAGE"
            ;;
        esac
    done

    # Only show config if explicitly requested or after setting DEBUG
    if [[ "$show_config" == "true" ]]; then
        print_config "$verbose"
    fi
    return "$EXIT_SUCCESS"
}

# Main menu function
main_menu() {
    [[ $# -eq 0 ]] && {
        show_help
        return 0
    }

    parse_args "$@"
}
