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

# Standard flag definitions
declare -A STANDARD_FLAGS=(
    [--help]="-h"
    [--debug]="-d"
    [--quiet]="-q"
    [--verbose]="-v"
    [--version]="-V"
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

# Show main help
show_help() {
    echo -e "${VERB}Usage: ${0##*/} [--debug] [--help] [command] [options]${RSET}"
    echo -e "\n${HIGH}Global Options:${RSET}"
    echo "  --debug, -d    Enable debug output"
    echo "  --help, -h     Show this help message"
    echo "  --version, -v  Show version information"

    echo -e "\n${HIGH}Commands:${RSET}"
    echo "  process  Process certificates (default command)"
    echo "  verify   Verify a certificate file"
    echo "  info     Show certificate information"
    echo "  config   Show or update configuration"
    echo "  help     Show this help message"

    echo -e "\n${HIGH}Process Options:${RSET}"
    echo "  --ca-skip           Skip processing ca-certificates.crt"
    echo "  --dod-skip          Skip processing DoD certificates"
    echo "  --org-skip          Skip processing organization certificates"
    echo "  --pem-file=FILE     Process organization certificates from combined PEM file"
    echo "  --individual        Process individual organization certificates"
    echo "  --fetch-dynamic     Fetch certificate list dynamically"
    echo "  --skip-update       Skip updating CA certificates store"
    echo "  --log-file=FILE     Enable logging to specified file"

    echo -e "\n${HIGH}Examples:${RSET}"
    echo "  ${0##*/} process --ca-skip --dod-skip --pem-file=my-certs.pem     Process combined PEM file"
    echo "  ${0##*/} process --ca-skip --dod-skip --individual                Process static org cert list"
    echo "  ${0##*/} process --ca-skip --dod-skip --individual --fetch-dynamic Use dynamic org certs list"
    echo "  ${0##*/} verify cert.pem                                          Verify single certificate"
    echo "  ${0##*/} info cert.pem -a                                         Show all certificate info"
}

# Show command-specific help
show_command_help() {
    local command="$1"

    case "$command" in
    process)
        echo -e "${VERB}Usage: ${0##*/} process [options]${RSET}"
        echo -e "\n${HIGH}Options:${RSET}"
        echo "  --ca-skip           Skip processing ca-certificates.crt"
        echo "  --dod-skip          Skip processing DoD certificates"
        echo "  --org-skip          Skip processing organization certificates"
        echo "  --pem-file=FILE     Process organization certificates from combined PEM file"
        echo "  --individual        Process individual organization certificates"
        echo "  --fetch-dynamic     Fetch certificate list dynamically"
        echo "  --skip-update       Skip updating CA certificates store"
        echo "  --log-file=FILE     Enable logging to file"
        ;;
    verify)
        echo -e "${VERB}Usage: ${0##*/} verify <certificate-file>${RSET}"
        echo -e "\n${HIGH}Options:${RSET}"
        echo "  --debug, -d    Enable debug output"
        ;;
    info)
        echo -e "${VERB}Usage: ${0##*/} info <certificate-file> [options]${RSET}"
        echo -e "\n${HIGH}Options:${RSET}"
        echo "  -s       Show subject only"
        echo "  -i       Show issuer only"
        echo "  -d       Show dates only"
        echo "  -a       Show all information"
        ;;
    config)
        echo -e "${VERB}Usage: ${0##*/} config [options]${RSET}"
        echo -e "\n${HIGH}Options:${RSET}"
        echo "  -s key=value  Set configuration value"
        echo "  -l           List current configuration"
        echo "  -v           Show verbose configuration"
        ;;
    *)
        show_help
        ;;
    esac
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

    # Show help without requiring initialization
    if [[ "$command" == "help" ]]; then
        [[ $# -gt 0 ]] && show_command_help "$1" || show_help
        return 0
    fi

    # Process global options first
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --*=*)
            local key=${1%%=*}
            local value=${1#*=}
            args+=("$key" "$value")
            shift
            ;;
        --*)
            args+=("$1")
            shift
            [[ -n "${1:-}" && ! "$1" =~ ^- ]] && {
                args+=("$1")
                shift
            }
            ;;
        -*)
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
    validate_certificate "$cert_file" "verify" true # Changed to use validate_certificate
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
            show_config=true
            verbose=true
            shift
            ;;
        --set)
            shift
            if [[ -z "${1:-}" ]] || [[ ! "$1" =~ = ]]; then
                error "Option --set requires KEY=VALUE argument"
                show_command_help "config"
                return $EXIT_INVALID_USAGE
            fi
            local key="${1%%=*}"
            # Don't allow setting debug via --set
            if [[ "$key" == "DEBUG" ]]; then
                error "DEBUG can only be set via environment or --debug flag"
                return $EXIT_INVALID_USAGE
            fi
            local value="${1#*=}"
            debug "Setting config: $key=$value"
            if ! set_config "$key" "$value"; then
                show_command_help "config"
                return $EXIT_INVALID_USAGE
            fi
            shift
            ;;
        *)
            error "Invalid option: $1"
            show_command_help "config"
            return $EXIT_INVALID_USAGE
            ;;
        esac
    done

    # Only show config if explicitly requested or after setting DEBUG
    if [[ "$show_config" == "true" ]]; then
        print_config "$verbose"
    fi
    return $EXIT_SUCCESS
}

# Main menu function
main_menu() {
    [[ $# -eq 0 ]] && {
        show_help
        return 0
    }

    parse_args "$@"
}
