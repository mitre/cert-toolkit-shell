#!/usr/bin/env bash

# Guard against multiple loading
if [[ -n "${TEST_HELPER_LOADED:-}" ]]; then
    return 0
fi
declare -r TEST_HELPER_LOADED=true

# Set up test environment with correct path resolution
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"
LIB_DIR="${PROJECT_ROOT}/src/lib"

# Export these before any other operations
export TEST_DIR PROJECT_ROOT LIB_DIR

# Verify paths exist
if [[ ! -d "$LIB_DIR" ]]; then
    echo "Error: Library directory not found: $LIB_DIR" >&2
    exit 1
fi

# Update PATH to include project binaries
PATH="${PROJECT_ROOT}/src:${LIB_DIR}:$PATH"
export PATH

# Load bats libraries if available
load_bats_libs() {
    if [[ -d "/usr/lib/bats" ]]; then
        load "/usr/lib/bats/bats-support/load"
        load "/usr/lib/bats/bats-assert/load"
        load "/usr/lib/bats/bats-file/load"
    fi
}

# Create temporary test directory
setup_test_dir() {
    TEST_TEMP_DIR="$(mktemp -d)"
    export TEST_TEMP_DIR
}

# Clean up temporary test directory
cleanup_test_dir() {
    if [[ -d "${TEST_TEMP_DIR:-}" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Create test certificate
create_test_cert() {
    local name="$1"
    local dir="${2:-$TEST_TEMP_DIR}"

    openssl req -x509 -newkey rsa:2048 -keyout "$dir/$name.key" \
        -out "$dir/$name.pem" -days 365 -nodes \
        -subj "/C=US/ST=MA/L=Bedford/O=MITRE/CN=test.mitre.org" 2>/dev/null
}

# Mock functions for system commands
mock_command() {
    local name="$1"
    local output="$2"
    local status="${3:-0}"

    eval "${name}() { echo \"$output\"; return $status; }"
}

# Assertion helpers
assert_debug_output() {
    local expected="$1"
    DEBUG=true
    run "$2"
    [[ "$output" =~ "$expected" ]]
}

assert_no_debug_output() {
    DEBUG=false
    run "$1"
    [ -z "$output" ]
}

# Load common test setup
setup_test_environment() {
    load_bats_libs
    setup_test_dir
}

# Load common test teardown
teardown_test_environment() {
    cleanup_test_dir
}
