#!/bin/bash

# Guard against multiple loading
if [[ -n "${HELP_LOADED:-}" ]]; then
    return 0
fi
declare -r HELP_LOADED=true

show_version() {
    echo "${SCRIPT_NAME} ${VERSION}"
    echo "Copyright (C) 2024 MITRE Corporation"
    echo "License Apache 2.0: Apache License Version 2.0"
    echo "This is free software: you are free to change and redistribute it."
    echo "There is NO WARRANTY, to the extent permitted by law."
}

show_usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [OPTION]... COMMAND [ARGS]...

Options:
  -h, --help     Display this help and exit
  -V, --version  Display version information and exit
  -v, --verbose  Increase verbosity
  -q, --quiet    Suppress non-error messages
  -d, --debug    Enable debug output

Commands:
  process        Process certificates (default)
  verify         Verify certificate
  info          Show certificate information
  config        Show/update configuration
  help          Show help for commands

Run '${SCRIPT_NAME} COMMAND --help' for command-specific help.
EOF
}

show_process_help() {
    cat <<EOF
Usage: ${SCRIPT_NAME} process [OPTIONS]...

Process and install certificates from various sources.

Options:
  --ca-skip              Skip processing ca-certificates.crt
  --dod-skip             Skip processing DoD certificates
  --org-skip             Skip processing organization certificates
  --pem-file=FILE       Process certificates from PEM file
  --individual          Process individual certificates
  --fetch-dynamic       Fetch certificate list dynamically
  --skip-update         Skip updating CA certificates store
  --log-file=FILE       Enable logging to specified file

Examples:
  ${SCRIPT_NAME} process                Process all certificates
  ${SCRIPT_NAME} process --ca-skip      Skip CA certificates
  ${SCRIPT_NAME} process --pem-file=FILE Process from PEM file
EOF
}

show_verify_help() {
    cat <<EOF
Usage: ${SCRIPT_NAME} verify [OPTIONS]... CERTIFICATE

Verify a certificate file.

Options:
  --verbose, -v  Show detailed certificate information
  --quiet, -q    Show only pass/fail status

Example:
  ${SCRIPT_NAME} verify cert.pem        Verify certificate
EOF
}

show_info_help() {
    cat <<EOF
Usage: ${SCRIPT_NAME} info [OPTIONS]... CERTIFICATE

Display certificate information.

Options:
  --subject, -s  Show subject only
  --issuer, -i   Show issuer only
  --dates, -d    Show validity dates only
  --all, -a      Show all information (default)

Example:
  ${SCRIPT_NAME} info --all cert.pem    Show all certificate details
EOF
}

show_config_help() {
    cat <<EOF
Usage: ${SCRIPT_NAME} config [OPTIONS]...

View or modify configuration settings.

Options:
  --set KEY=VALUE       Set configuration value
  --list               List basic configuration
  --verbose            Show detailed configuration
  --help               Show this help message

Example:
  ${SCRIPT_NAME} config --list              Show basic configuration
  ${SCRIPT_NAME} config --verbose           Show detailed configuration
  ${SCRIPT_NAME} config --set DEBUG=true    Enable debug mode
EOF
}

show_command_help() {
    local command="$1"
    case "$command" in
    process) show_process_help ;;
    verify) show_verify_help ;;
    info) show_info_help ;;
    config) show_config_help ;;
    *) show_usage ;;
    esac
}
