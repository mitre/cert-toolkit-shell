#!/usr/bin/env bash

# Load BATS helpers
load "$(brew --prefix)/lib/bats-support/load.bash"
load "$(brew --prefix)/lib/bats-assert/load.bash"
load "$(brew --prefix)/lib/bats-file/load.bash"

# Global state for test environment
export BATS_TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(cd "${BATS_TEST_ROOT}/.." && pwd)"
export TEST_ROOT="${BATS_TEST_ROOT}"
export TEST_FIXTURES="${TEST_ROOT}/fixtures"
export TEST_TEMP="${BATS_TMPDIR:-/tmp}/bats-$$"

# Debug helper - more concise output
debug() {
    if [[ "${DEBUG:-}" == "true" ]]; then
        printf "# %-20s: %s\n" "$1" "$2" >&3
    fi
}

# Global setup function
setup_test_environment() {
    mkdir -p "${TEST_FIXTURES}" "${TEST_TEMP}"

    if [[ "${DEBUG:-}" == "true" ]]; then
        debug "Test Paths" "--------"
        debug "PROJECT_ROOT" "${PROJECT_ROOT}"
        debug "TEST_ROOT" "${TEST_ROOT}"
        debug "TEST_FIXTURES" "${TEST_FIXTURES}"
        debug "TEST_TEMP" "${TEST_TEMP}"
    fi
}

# Default setup (will be called before each test)
setup() {
    setup_test_environment
}

# Cleanup with debug info
teardown() {
    if [[ -d "${TEST_TEMP}" && -n "${TEST_TEMP}" ]]; then
        debug "Cleanup" "${TEST_TEMP}"
        rm -rf "${TEST_TEMP}"
    fi
}
