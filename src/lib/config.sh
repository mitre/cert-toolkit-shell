#!/bin/bash

# Guard against multiple loading
if [[ -n "${CONFIG_LOADED:-}" ]]; then
    return 0
fi
declare -r CONFIG_LOADED=true

# Environment variable prefixes
declare -r ENV_PREFIX="CERT_TOOLKIT_"
declare -r ENV_DEBUG="${ENV_PREFIX}DEBUG"
declare -r ENV_VERBOSE="${ENV_PREFIX}VERBOSE"
declare -r ENV_QUIET="${ENV_PREFIX}QUIET"
declare -r ENV_CONFIG="${ENV_PREFIX}CONFIG"
declare -r ENV_CERT_DIR="${ENV_PREFIX}CERT_DIR"

# Configuration defaults
declare -A CONFIG=(
    # CRITICAL: Debug initialization
    # This must be initialized from environment immediately
    # Other modules depend on this being set correctly at load time
    [DEBUG]="${DEBUG:-${CERT_TOOLKIT_DEBUG:-false}}"
    # URLs
    [DOD_CERT_URL]='https://public.cyber.mil/pki-pke/pkipke-document-library/'
    [ORG_CERT_BASE_URL]='https://pkirepo.mitre.org/Certificates'

    # File paths
    [ORG_COMBINED_CERT_FILE]='.devcontainer/extra-ca.pem'
    [DEFAULT_CERT_DIR_DEBIAN]='/usr/local/share/ca-certificates'
    [DEFAULT_CERT_DIR_REDHAT]='/etc/pki/ca-trust/source/anchors'

    # Set initial CERT_DIR to prevent empty base
    [CERT_DIR]='/usr/local/share/ca-certificates'

    # Processing flags
    [PROCESS_CA_CERTS]='true'
    [PROCESS_DOD_CERTS]='true'
    [PROCESS_ORG_CERTS]='true'
    [SKIP_UPDATE]='false'

    # Certificate processing options
    [USE_COMBINED_PEM]='false'
    [USE_INDIVIDUAL_CERTS]='false'
    [USE_DYNAMIC_LIST]='false'
    [COMBINED_PEM_FILE]=''

    # Debug settings - initialize from environment immediately
    [DEBUG]="${DEBUG:-${CERT_TOOLKIT_DEBUG:-false}}"
)

# Default organization certificates array
declare -a DEFAULT_ORG_CERTS=(
    "Entrust Managed Services NFI Root CA.crt"
    "Entrust NFI Medium Assurance SSP CA.crt"
    "MITRE BA NPE CA-3(1).crt"
    "MITRE BA NPE CA-3.crt"
    "MITRE BA NPE CA-4.crt"
    "MITRE BA ROOT.crt"
    "MITRE Corporation PE CA-2(1).crt"
    "MITRE Corporation PE CA-2(2).crt"
    "MITRE Corporation PE CA-2.crt"
    "MITRE Corporation PE Root CA-1.crt"
    "MITRE PE CA-4.crt"
    "MITRE-NPE-CA1.crt"
    "ZScaler_Root.crt"
)

# Initialize configuration from environment
init_env_config() {
    # CRITICAL: Debug propagation
    # This section must run first to ensure proper debug state
    # Do not move or modify without careful testing
    if [[ "${DEBUG:-false}" == "true" || "${CERT_TOOLKIT_DEBUG:-false}" == "true" || "${CONFIG[DEBUG]}" == "true" ]]; then
        CONFIG[DEBUG]="true"
        export DEBUG=true
        export CERT_TOOLKIT_DEBUG=true
        # Ensure debug is initialized before using debug function
        echo "Debug mode enabled via environment" >&2
    else
        CONFIG[DEBUG]="false"
        unset DEBUG CERT_TOOLKIT_DEBUG
    fi

    # Process other environment variables
    local config_file="${CERT_TOOLKIT_CONFIG:-}"

    # Load custom config file if specified
    # shellcheck source=/dev/null
    [[ -n "$config_file" && -f "$config_file" ]] && source "$config_file"

    # Now we can safely use debug function
    debug "Setting environment config values"

    # Force debug setting to match environment
    [[ "${DEBUG:-false}" == "true" ]] && CONFIG[DEBUG]="true"

    # Process other environment variables
    local verbose_val="${CERT_TOOLKIT_VERBOSE:-}"
    local quiet_val="${CERT_TOOLKIT_QUIET:-}"
    local cert_dir_val="${CERT_TOOLKIT_CERT_DIR:-}"

    [[ -n "$verbose_val" ]] && CONFIG[VERBOSE]="$verbose_val"
    [[ -n "$quiet_val" ]] && CONFIG[QUIET]="$quiet_val"
    [[ -n "$cert_dir_val" ]] && CONFIG[CERT_DIR]="$cert_dir_val"

    # One final check for debug state
    debug "Debug state: ${CONFIG[DEBUG]}"
}

# Initialize configuration
init_config() {
    local config_file="${1:-}"

    # Initialize from environment first
    init_env_config

    debug "Initializing configuration"

    # Load custom config file if provided
    if [[ -n "$config_file" && -f "$config_file" ]]; then
        debug "Loading configuration from: $config_file"
        source "$config_file"
    fi

    # Set OS-specific paths
    local os_type
    os_type=$(get_os_type)
    debug "Detected OS type: $os_type"

    case "$os_type" in
    "debian")
        CONFIG[CERT_DIR]="${CONFIG[DEFAULT_CERT_DIR_DEBIAN]}"
        debug "Using Debian certificate directory: ${CONFIG[CERT_DIR]}"
        ;;
    "redhat")
        CONFIG[CERT_DIR]="${CONFIG[DEFAULT_CERT_DIR_REDHAT]}"
        debug "Using RedHat certificate directory: ${CONFIG[CERT_DIR]}"
        ;;
    *)
        error "Unsupported operating system: $os_type"
        return 1
        ;;
    esac

    # Create certificate directories
    ensure_directory "${CONFIG[CERT_DIR]}/org"
    ensure_directory "${CONFIG[CERT_DIR]}/dod"

    debug "Configuration initialized successfully"
    return 0
}

# Get configuration value
get_config() {
    local key="$1"
    local default_value="${2:-}"

    if [[ -n "${CONFIG[$key]+x}" ]]; then
        echo "${CONFIG[$key]}"
    else
        echo "$default_value"
    fi
}

# Update set_config for better validation
set_config() {
    local key="$1"
    local value="$2"

    if [[ -z "$key" ]]; then
        error "Configuration key cannot be empty"
        return $EXIT_INVALID_USAGE
    fi

    if [[ ! -v "CONFIG[$key]" ]]; then
        error "Invalid configuration key: $key"
        return $EXIT_INVALID_USAGE
    fi

    CONFIG[$key]="$value"
    debug "Configuration updated: $key=$value"

    # Special handling for DEBUG setting
    if [[ "$key" == "DEBUG" && "$value" == "true" ]]; then
        export DEBUG=true
        export CERT_TOOLKIT_DEBUG=true
    fi

    return $EXIT_SUCCESS
}

# Update configuration from command line arguments
update_config_from_args() {
    while getopts ":cdop:ifsDh" opt; do
        case $opt in
        c) set_config "PROCESS_CA_CERTS" "false" ;;
        d) set_config "PROCESS_DOD_CERTS" "false" ;;
        o) set_config "PROCESS_ORG_CERTS" "false" ;;
        p)
            if [[ -z "$OPTARG" ]]; then
                error "-p requires a filename argument"
                return 1
            fi
            set_config "USE_COMBINED_PEM" "true"
            set_config "COMBINED_PEM_FILE" "$OPTARG"
            ;;
        i) set_config "USE_INDIVIDUAL_CERTS" "true" ;;
        f)
            set_config "USE_DYNAMIC_LIST" "true"
            set_config "USE_INDIVIDUAL_CERTS" "true"
            ;;
        s) set_config "SKIP_UPDATE" "true" ;;
        D) set_config "DEBUG" "true" ;;
        h) return 0 ;;
        :)
            error "Option -$OPTARG requires an argument"
            return 1
            ;;
        \?)
            error "Invalid option -$OPTARG"
            return 1
            ;;
        esac
    done
    return 0
}

# Validate configuration
validate_config() {
    local errors=0

    # Check required URLs
    if [[ -z "$(get_config DOD_CERT_URL)" ]]; then
        error "DOD_CERT_URL is not set"
        ((errors++))
    fi

    if [[ -z "$(get_config ORG_CERT_BASE_URL)" ]]; then
        error "ORG_CERT_BASE_URL is not set"
        ((errors++))
    fi

    # Check certificate directory
    if [[ ! -d "$(get_config CERT_DIR)" ]]; then
        error "Certificate directory does not exist: $(get_config CERT_DIR)"
        ((errors++))
    fi

    # Validate combined PEM file if specified
    if [[ "$(get_config USE_COMBINED_PEM)" == "true" ]]; then
        if [[ -z "$(get_config COMBINED_PEM_FILE)" ]]; then
            error "Combined PEM file not specified"
            ((errors++))
        elif [[ ! -f "$(get_config COMBINED_PEM_FILE)" ]]; then
            error "Combined PEM file not found: $(get_config COMBINED_PEM_FILE)"
            ((errors++))
        fi
    fi

    return $errors
}

# Print current configuration
print_config() {
    local verbose="${1:-false}"

    echo -e "${HIGH}Current Configuration:${RSET}"
    echo -e "${VERB}Certificate Directories:${RSET}"
    echo "  Base: $(get_config CERT_DIR)"
    echo "  DoD:  $(get_config CERT_DIR)/dod"
    echo "  Org:  $(get_config CERT_DIR)/org"

    echo -e "\n${VERB}Processing Flags:${RSET}"
    echo "  Process CA Certs:   $(get_config PROCESS_CA_CERTS)"
    echo "  Process DoD Certs:  $(get_config PROCESS_DOD_CERTS)"
    echo "  Process Org Certs:  $(get_config PROCESS_ORG_CERTS)"
    echo "  Skip Update:        $(get_config SKIP_UPDATE)"

    # Only show extended info if verbose is true
    if [[ "$verbose" == "true" ]]; then
        echo -e "\n${VERB}URLs:${RSET}"
        echo "  DoD Cert URL:     $(get_config DOD_CERT_URL)"
        echo "  Org Cert Base URL:$(get_config ORG_CERT_BASE_URL)"

        echo -e "\n${VERB}Certificate Processing Options:${RSET}"
        echo "  Use Combined PEM:     $(get_config USE_COMBINED_PEM)"
        echo "  Use Individual Certs: $(get_config USE_INDIVIDUAL_CERTS)"
        echo "  Use Dynamic List:     $(get_config USE_DYNAMIC_LIST)"

        if [[ "$(get_config USE_COMBINED_PEM)" == "true" ]]; then
            echo "  Combined PEM File:    $(get_config COMBINED_PEM_FILE)"
        fi

        echo -e "\n${VERB}Debug Mode:${RSET} $(get_config DEBUG)"
    fi
}
