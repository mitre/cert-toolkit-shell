#!/bin/bash
# Imports DoD root certificates into Linux CA store
# Version 1.0.0 updated 20240116
# Usage: ./cert-manager.sh [command] [options]
# License: Apache License 2.0
#
# For issues or updated versions, visit:
# https://github.com/mitre/cert-toolkit/
#
# Dependencies:
# - curl gawk openssl unzip wget
#- libxml2-utils (Debian) or libxml2 (RedHat)

set -euo pipefail
shopt -s extdebug nullglob

# Version information
VERSION="1.0.0"
DESCRIPTION="Certificate Management Tool"
SCRIPT_NAME="${0##*/}"

# Import core module only - it will handle all other module loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

# Parse common flags before command processing
while [[ $# -gt 0 ]]; do
    case "$1" in
    --debug | -d)
        export DEBUG=true
        export CERT_TOOLKIT_DEBUG=true
        shift
        ;;
    --help | -h)
        SHOW_HELP=true
        shift
        ;;
    --version | -v)
        echo "$SCRIPT_NAME version $VERSION"
        exit 0
        ;;
    --)
        shift
        break
        ;;
    -*)
        # Stop processing at first non-recognized flag
        break
        ;;
    *)
        break
        ;;
    esac
done

# Set debug mode if specified
[[ "${DEBUG:-false}" == "true" ]] && {
    echo "Debug mode enabled"
    echo "Script directory: ${SCRIPT_DIR}"
    echo "Library directory: ${LIB_DIR}"
    ls -la "${LIB_DIR}"
}

# Load core module which handles all other module loading
if ! source "${LIB_DIR}/core.sh"; then
    echo "Error: Failed to load core module"
    echo "Script directory: ${SCRIPT_DIR}"
    echo "Library directory: ${LIB_DIR}"
    ls -la "${LIB_DIR}"
    exit 1
fi

# Show help if requested (after debug flag processing)
if [[ "${SHOW_HELP:-false}" == "true" ]]; then
    show_help
    exit 0
fi

# Process commands through menu system
if ! main_menu "$@"; then
    error "Command execution failed"
    exit 1
fi

exit 0
