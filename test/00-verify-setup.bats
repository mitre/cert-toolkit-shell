#!/usr/bin/env bats

# Load test helper directly
load 'test_helper'

# Enhanced debug output in setup
setup() {
    if [[ "${DEBUG:-}" = "true" ]]; then
        echo "# ==========================" >&3
        echo "# BATS Environment Variables:" >&3
        echo "# BATS_TEST_DIRNAME: ${BATS_TEST_DIRNAME}" >&3
        echo "# BATS_TEST_FILENAME: ${BATS_TEST_FILENAME}" >&3
        echo "# BATS_TMPDIR: ${BATS_TMPDIR}" >&3
        echo "# BATS_RUN_TMPDIR: ${BATS_RUN_TMPDIR}" >&3
        echo "# ==========================" >&3
        echo "# Test Environment:" >&3
        echo "# PROJECT_ROOT: ${PROJECT_ROOT}" >&3
        echo "# TEST_ROOT: ${TEST_ROOT}" >&3
        echo "# TEST_FIXTURES: ${TEST_FIXTURES}" >&3
        echo "# TEST_TEMP: ${TEST_TEMP}" >&3
        echo "# ==========================" >&3
        echo "# System Information:" >&3
        echo "# PWD: $(pwd)" >&3
        echo "# PATH: ${PATH}" >&3
        echo "# OS: $(uname -s)" >&3
        echo "# ==========================" >&3
    fi
}

# Add debug output without overriding setup
debug_environment() {
    if [[ "${DEBUG:-}" = "true" ]]; then
        echo "# ==========================" >&3
        echo "# BATS Environment Variables:" >&3
        echo "# BATS_TEST_DIRNAME: ${BATS_TEST_DIRNAME}" >&3
        echo "# BATS_TEST_FILENAME: ${BATS_TEST_FILENAME}" >&3
        echo "# BATS_TMPDIR: ${BATS_TMPDIR}" >&3
        echo "# BATS_RUN_TMPDIR: ${BATS_RUN_TMPDIR}" >&3
        echo "# ==========================" >&3
        echo "# Test Environment:" >&3
        echo "# PROJECT_ROOT: ${PROJECT_ROOT}" >&3
        echo "# TEST_ROOT: ${TEST_ROOT}" >&3
        echo "# TEST_FIXTURES: ${TEST_FIXTURES}" >&3
        echo "# TEST_TEMP: ${TEST_TEMP}" >&3
        echo "# ==========================" >&3
        echo "# System Information:" >&3
        echo "# PWD: $(pwd)" >&3
        echo "# PATH: ${PATH}" >&3
        echo "# OS: $(uname -s)" >&3
        echo "# ==========================" >&3
    fi
}

show_environment() {
    if [[ "${DEBUG:-}" = "true" ]]; then
        debug "BATS" "-----------------"
        debug "TEST_DIRNAME" "${BATS_TEST_DIRNAME}"
        debug "TEST_FILENAME" "${BATS_TEST_FILENAME}"
        debug "TMPDIR" "${BATS_TMPDIR}"

        debug "System" "-----------------"
        debug "OS" "$(uname -s)"
        debug "PWD" "$(pwd)"
    fi
}

@test "verify bats works" {
    run bats --version
    [ "$status" -eq 0 ]
}

@test "verify all required commands exist" {
    for cmd in bats openssl curl wget sed date; do
        run command -v "$cmd"
        assert_success
        if [[ "${DEBUG:-}" = "true" ]]; then
            echo "# $cmd location: $output" >&3
        fi
    done
}

@test "verify openssl version is 3.x" {
    run openssl version
    assert_success
    assert_output --partial "3."
}

@test "verify bats-support is available" {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        assert [ -d "$(brew --prefix)/lib/bats-support" ]
    else
        assert [ -d "/usr/lib/bats/bats-support" ]
    fi
}

@test "verify bats-assert is available" {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        assert [ -d "$(brew --prefix)/lib/bats-assert" ]
    else
        assert [ -d "/usr/lib/bats/bats-assert" ]
    fi
}

@test "verify GNU tools are available" {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        run sed --version
        assert_output --partial "GNU sed"

        run date --version
        assert_output --partial "GNU coreutils"
    fi
}

@test "verify OpenSSL is available" {
    run openssl version
    assert_success
    assert_output --partial "OpenSSL"
}

@test "verify test environment variables" {
    show_environment
    setup_test_environment

    # Test paths are set and exist
    assert [ -n "${TEST_ROOT}" ]
    assert [ -d "${TEST_ROOT}" ]
    assert [ -n "${PROJECT_ROOT}" ]
    assert [ -d "${PROJECT_ROOT}" ]
    assert [ -n "${TEST_FIXTURES}" ]
    assert [ -d "${TEST_FIXTURES}" ]
    assert [ -n "${TEST_TEMP}" ]
    assert [ -d "${TEST_TEMP}" ]
}

@test "verify test directories exist" {
    local dirs=(
        "test/fixtures"
        "test/unit"
        "test/integration"
    )

    for dir in "${dirs[@]}"; do
        assert_dir_exist "$dir"
        if [[ "${DEBUG:-}" = "true" ]]; then
            echo "# Directory contents of $dir:" >&3
            ls -la "$dir" >&3
        fi
    done
}
