#!/usr/bin/env bash

# Debug output helper
debug() {
    if [[ "${DEBUG:-}" = "true" ]]; then
        echo "# $*" >&3
    fi
}

# System information helper
debug_system_info() {
    debug "Operating System: $(uname -s)"
    debug "PATH: ${PATH}"
    debug "Shell: ${SHELL}"
    debug "Homebrew prefix (if exists): $(brew --prefix 2>/dev/null || echo 'not found')"
    debug "OpenSSL version: $(openssl version)"
    debug "BATS version: $(bats --version)"
}

# Test environment helper
debug_test_env() {
    debug "Test Directory: ${BATS_TEST_DIRNAME}"
    debug "Temp Directory: ${BATS_TEST_TMPDIR}"
    debug "Test Filename: ${BATS_TEST_FILENAME}"
}

# Command verification helper
debug_verify_cmd() {
    local cmd=$1
    if command -v "$cmd" >/dev/null 2>&1; then
        debug "$cmd found at: $(command -v "$cmd")"
        return 0
    else
        debug "$cmd not found"
        return 1
    fi
}
