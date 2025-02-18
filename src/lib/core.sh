#!/bin/bash

# Guard against multiple loading
if [[ -n "${CORE_LOADED:-}" ]]; then
    return 0
fi
declare -r CORE_LOADED=true

# Set script directory for module loading
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Import exit codes
source "$(dirname "${BASH_SOURCE[0]}")/exit_codes.sh"

# Signal handling
handle_signal() {
    local sig="$1"
    if [[ "$sig" == "EXIT" ]]; then
        cleanup
        return 0
    fi
    echo -e "\n${WARN}Received signal: $sig${RSET}" >&2
    cleanup
    exit $EXIT_ERROR
}

cleanup() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        debug "Performing cleanup"
    fi
    # Clean up temporary files
    find "${TMPDIR:-/tmp}" -maxdepth 1 -name "cert-toolkit.*" -user "$(id -u)" -delete 2>/dev/null || true
    # Reset terminal if interactive
    [[ -t 1 ]] && tput cnorm 2>/dev/null || true
}

# Set up signal handling
trap 'handle_signal INT' INT
trap 'handle_signal TERM' TERM
trap 'handle_signal EXIT' EXIT

# Define module loading order
# See: ./lib/README.md for order and module descriptions
# CRITICAL: Module loading order
# debug.sh must be loaded early but after utils.sh
# config.sh must maintain debug state during initialization
declare -ar MODULE_ORDER=(
    "utils.sh"      # Base utilities (required first)
    "debug.sh"      # Logging system (required early)
    "metrics.sh"    # Metrics tracking
    "config.sh"     # Configuration management (maintains debug state)
    "validators.sh" # Certificate validation
    "processors.sh" # Certificate processing
    "menu.sh"       # User interface
)

# Load each module once
for module in "${MODULE_ORDER[@]}"; do
    if [[ ! -f "${LIB_DIR}/${module}" ]]; then
        echo "Error: Required module not found: ${module}"
        echo "Directory: ${LIB_DIR}"
        exit 1
    fi

    if ! source "${LIB_DIR}/${module}"; then
        echo "Error: Failed to load module: ${module}"
        exit 1
    fi
done

# Initialize the application
init_application() {
    local config_file="${1:-}"

    debug "Initializing application"
    debug "Configuration file: ${config_file:-none}"

    # Initialize all modules
    init_metrics
    init_config "$config_file" || return 1

    # Ensure required packages are installed
    local required_packages=("curl" "gawk" "openssl" "unzip" "wget")
    local xml_package="libxml2-utils"
    [[ "$(get_os_type)" == "redhat" ]] && xml_package="libxml2"

    for package in "${required_packages[@]}" "$xml_package"; do
        if ! is_package_installed "$package"; then
            debug "Installing package: $package"
            if ! install_package "$package"; then
                if [[ "$package" == "$xml_package" ]]; then
                    warn "XML processing will use fallback method"
                else
                    error "Failed to install required package: $package"
                    return 1
                fi
            fi
        fi
    done

    return 0
}

# Main processing function
process_certificates() {
    local verbose="${1:-false}"
    local status=0

    # Process CA certificates if enabled
    if [[ "$(get_config PROCESS_CA_CERTS)" == "true" ]]; then
        debug "Processing CA certificates"
        if ! process_ca_certificates "$verbose"; then
            error "CA certificate processing failed"
            ((status++))
        fi
    else
        debug "Skipping CA certificates processing"
    fi

    # Process DoD certificates if enabled
    if [[ "$(get_config PROCESS_DOD_CERTS)" == "true" ]]; then
        debug "Processing DoD certificates"
        if ! process_dod_certs "$(get_config CERT_DIR)/dod" "$verbose"; then
            error "DoD certificate processing failed"
            ((status++))
        fi
    else
        debug "Skipping DoD certificates processing"
    fi

    # Process organization certificates if enabled
    if [[ "$(get_config PROCESS_ORG_CERTS)" == "true" ]]; then
        debug "Processing organization certificates"
        local org_status=0

        if [[ "$(get_config USE_COMBINED_PEM)" == "true" ]]; then
            # Process combined PEM file
            if ! process_bundle "$(get_config COMBINED_PEM_FILE)" \
                "$(get_config CERT_DIR)/org" "org" "$verbose"; then
                error "Combined PEM processing failed"
                ((org_status++))
            fi
        elif [[ "$(get_config USE_INDIVIDUAL_CERTS)" == "true" ]]; then
            # Process individual certificates
            local cert_list=()

            if [[ "$(get_config USE_DYNAMIC_LIST)" == "true" ]]; then
                # Fetch dynamic list
                while IFS= read -r cert; do
                    [[ -n "$cert" ]] && cert_list+=("$cert")
                done < <(fetch_cert_list)

                if [[ ${#cert_list[@]} -eq 0 ]]; then
                    warn "No certificates found in repository, using default list"
                    cert_list=("${DEFAULT_ORG_CERTS[@]}")
                fi
            else
                cert_list=("${DEFAULT_ORG_CERTS[@]}")
            fi

            # Process each certificate
            for cert in "${cert_list[@]}"; do
                debug "Processing certificate: $cert"
                if ! process_org_certificate "$cert" "$(get_config CERT_DIR)/org" "$verbose"; then
                    warn "Failed to process certificate: $cert"
                    ((org_status++))
                fi
            done
        fi

        ((status += org_status))
    else
        debug "Skipping organization certificates processing"
    fi

    # Update CA store if not skipped
    if [[ "$(get_config SKIP_UPDATE)" != "true" ]]; then
        debug "Updating CA certificates store"
        if ! update_ca_store "$verbose"; then
            error "CA store update failed"
            ((status++))
        fi
    else
        debug "Skipping CA store update"
    fi

    return $status
}

# Main execution function
main() {
    local config_file="${1:-}"
    local verbose=false

    # Initialize application
    if ! init_application "$config_file"; then
        error "Application initialization failed"
        return 1
    fi

    # Parse command line arguments through menu system
    if ! parse_args "$@"; then
        error "Failed to parse command line arguments"
        return 1
    fi

    # Set verbose mode based on debug setting
    [[ "$(get_config DEBUG)" == "true" ]] && verbose=true

    # Validate configuration
    if ! validate_config; then
        error "Configuration validation failed"
        return 1
    fi

    # Display configuration if in debug mode
    $verbose && print_config true

    # Process certificates
    if ! process_certificates "$verbose"; then
        error "Certificate processing failed"
        return 1
    fi

    # Print metrics
    print_metrics "$verbose"

    return 0
}

# Only execute if run directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
    exit $?
fi
