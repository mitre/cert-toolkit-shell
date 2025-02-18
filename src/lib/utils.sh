#!/bin/bash

# Guard against multiple loading
if [[ -n "${UTILS_LOADED:-}" ]]; then
    return 0
fi
declare -r UTILS_LOADED=true

# Color definitions only - debug functions moved to debug.sh
# Only declare if not already defined
[[ -z "${WARN:-}" ]] && declare -r WARN='\033[1;33m'
[[ -z "${RSET:-}" ]] && declare -r RSET='\033[0m'
[[ -z "${VERB:-}" ]] && declare -r VERB='\033[1;34m'
[[ -z "${HIGH:-}" ]] && declare -r HIGH='\033[1;32m'
[[ -z "${FAIL:-}" ]] && declare -r FAIL='\033[1;31m'
[[ -z "${PASS:-}" ]] && declare -r PASS='\033[1;32m'

# Standard I/O handling
read_input() {
    local prompt="$1"
    local default="${2:-}"
    local result

    # Show prompt with default if provided
    if [[ -n "$default" ]]; then
        printf "%s [%s]: " "$prompt" "$default" >&2
    else
        printf "%s: " "$prompt" >&2
    fi

    # Read input or use default
    read -r result
    echo "${result:-$default}"
}

confirm() {
    local prompt="$1"
    local default="${2:-y}"
    local response

    while true; do
        response=$(read_input "$prompt (y/n)" "$default")
        case "${response,,}" in
        y | yes) return 0 ;;
        n | no) return 1 ;;
        *) echo "Please answer yes or no" >&2 ;;
        esac
    done
}

# Package management
is_package_installed() {
    local package="$1"
    if command -v dpkg-query &>/dev/null; then
        dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "ok installed"
    elif command -v rpm &>/dev/null; then
        rpm -q "$package" &>/dev/null
    else
        command -v "$package" &>/dev/null
    fi
}

install_package() {
    local package="$1"
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y "$package"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "$package"
    elif command -v yum &>/dev/null; then
        sudo yum install -y "$package"
    else
        error "No supported package manager found"
        return 1
    fi
}

# File system operations
ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        debug "Creating directory: $dir"
        sudo mkdir -p "$dir" || error "Failed to create directory: $dir"
    fi
}

create_temp_dir() {
    local tmp_dir
    tmp_dir=$(mktemp -d) || error "Failed to create temporary directory"
    debug "Created temporary directory: $tmp_dir"
    echo "$tmp_dir"
}

cleanup_temp() {
    local dir="$1"
    [[ -d "$dir" ]] && rm -rf "$dir"
    debug "Cleaned up temporary directory: $dir"
}

# System detection
get_os_type() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        if [[ ${ID:-} =~ (fedora|rhel|centos) || ${ID_LIKE:-} =~ (fedora|rhel|centos) ]]; then
            echo "redhat"
        elif [[ ${ID:-} =~ (debian|ubuntu|mint) || ${ID_LIKE:-} =~ (debian|ubuntu|mint) ]]; then
            echo "debian"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# URL handling
download_file() {
    local url="$1"
    local output_file="$2"
    local quiet="${3:-false}"

    if ! wget -q "$url" -O "$output_file"; then
        error "Failed to download: $url"
        return 1
    fi
    $quiet || echo -e "${PASS}Downloaded: ${output_file}${RSET}"
    return 0
}
