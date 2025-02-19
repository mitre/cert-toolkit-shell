#!/usr/bin/env bats

# Set strict mode for BATS testing
set -euo pipefail
shopt -s extdebug

# Set critical path variables
export TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(cd "${TEST_DIR}/.." && pwd)"
export LIB_DIR="${PROJECT_ROOT}/src/lib"
export PATH="${PROJECT_ROOT}/src:${PATH}"

# Color definitions for test output
export FAIL="\033[0;31m" # Red for failures
export WARN="\033[0;33m" # Yellow for warnings
export HIGH="\033[0;34m" # Blue for highlights
export VERB="\033[0;36m" # Cyan for verbose
export RSET="\033[0m"    # Reset color

# Test environment validation
if [[ ! -d "$LIB_DIR" ]]; then
    echo "ERROR: Library directory not found: $LIB_DIR"
    echo "TEST_DIR=$TEST_DIR"
    echo "PROJECT_ROOT=$PROJECT_ROOT"
    exit 1
fi

# Load required test support files
load "${BATS_TEST_DIRNAME}/support/assertions.bash"

# Test suite setup - runs once before all tests
setup_suite() {
    # Ensure clean environment
    unset DEBUG CERT_TOOLKIT_DEBUG

    # Create test directories if needed
    mkdir -p "${BATS_TEST_TMPDIR}/certs"
    mkdir -p "${BATS_TEST_TMPDIR}/config"
}

# Test suite teardown - runs once after all tests
teardown_suite() {
    # Clean up test directories
    rm -rf "${BATS_TEST_TMPDIR}/certs"
    rm -rf "${BATS_TEST_TMPDIR}/config"
}

# Individual test setup - runs before each test
setup() {
    # Reset environment for each test
    unset DEBUG CERT_TOOLKIT_DEBUG

    # Create test-specific temporary directory
    TEST_TEMP_DIR="$(mktemp -d "${BATS_TEST_TMPDIR}/test.XXXXXX")"

    # Set test-specific environment variables
    export TEST_TEMP_DIR
    export CERT_DIR="${TEST_TEMP_DIR}/certs"
    export CONFIG_DIR="${TEST_TEMP_DIR}/config"

    # Create test-specific directories
    mkdir -p "$CERT_DIR"
    mkdir -p "$CONFIG_DIR"
}

# Individual test teardown - runs after each test
teardown() {
    # Clean up test-specific temporary directory
    if [[ -n "${TEST_TEMP_DIR:-}" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi

    # Reset environment variables
    unset TEST_TEMP_DIR CERT_DIR CONFIG_DIR
    unset DEBUG CERT_TOOLKIT_DEBUG
}

# Test helper functions
create_test_cert() {
    local name="$1"
    local dir="${2:-$CERT_DIR}"
    local subj="/CN=$name/O=Test Organization/C=US"

    mkdir -p "$dir"
    openssl req -x509 -newkey rsa:2048 -nodes \
        -keyout "$dir/$name.key" \
        -out "$dir/$name.crt" \
        -days 365 -subj "$subj" 2>/dev/null
}

create_test_config() {
    local name="$1"
    local content="$2"
    local dir="${3:-$CONFIG_DIR}"

    mkdir -p "$dir"
    echo "$content" >"$dir/$name"
}

skip_if_no_openssl() {
    if ! command -v openssl >/dev/null; then
        skip "openssl not available"
    fi
}

skip_if_no_curl() {
    if ! command -v curl >/dev/null; then
        skip "curl not available"
    fi
}

skip_if_root() {
    if [[ "$(id -u)" -eq 0 ]]; then
        skip "test cannot run as root"
    fi
}

skip_if_no_certificates() {
    if [[ ! -d "${PROJECT_ROOT}/test/fixtures/certs" ]]; then
        skip "test certificates not available"
    fi
}
