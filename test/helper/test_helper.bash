#!/usr/bin/env bash

# Load bats-support and bats-assert
load '../lib/bats-support/load'
load '../lib/bats-assert/load'

# Setup test environment
setup_suite() {
    # Create static test directory
    export TESTS_DIR="$BATS_TEST_DIRNAME"
    export TEST_DATA_DIR="$TESTS_DIR/fixtures"
    export TEST_TEMP_DIR="$BATS_FILE_TMPDIR"
}

# Teardown test environment
teardown_suite() {
    rm -rf "$TEST_TEMP_DIR"
}

# Initialize test environment variables
BATS_TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(cd "${BATS_TEST_ROOT}/.." && pwd)"
TEST_ROOT="${BATS_TEST_ROOT}"
TEST_FIXTURES="${TEST_ROOT}/fixtures"
TEST_TEMP="${BATS_TMPDIR:-/tmp}/bats-$$"

# Export for use in tests
export BATS_TEST_ROOT PROJECT_ROOT TEST_ROOT TEST_FIXTURES TEST_TEMP

# Setup function for tests
setup() {
    setup_test_environment
}

# Cleanup after tests
teardown() {
    if [[ -d "${TEST_TEMP}" && -n "${TEST_TEMP}" ]]; then
        rm -rf "${TEST_TEMP}"
    fi
}

# Debug output helper
debug() {
    if [[ "${DEBUG:-}" == "true" ]]; then
        printf "# %-20s: %s\n" "$1" "$2" >&3
    fi
}
