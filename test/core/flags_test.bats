#!/usr/bin/env bats

load '../test_helper'

setup() {
    # Get absolute paths relative to this test file
    TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"
    LIB_DIR="${PROJECT_ROOT}/src/lib"

    # Source required files using relative paths
    source "${LIB_DIR}/utils.sh"
    source "${LIB_DIR}/debug.sh"
    source "${PROJECT_ROOT}/src/cert-manager.sh"
}

teardown() {
    unset DEBUG CERT_TOOLKIT_DEBUG SHOW_HELP
}

@test "debug flag sets environment correctly" {
    run "${BATS_TEST_DIRNAME}/../../src/cert-manager.sh" --debug --help
    [ "$status" -eq 0 ]
    [ "${DEBUG:-}" = "true" ]
    [ "${CERT_TOOLKIT_DEBUG:-}" = "true" ]
}

@test "help flag shows usage" {
    run "${BATS_TEST_DIRNAME}/../../src/cert-manager.sh" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "version flag shows version" {
    run "${BATS_TEST_DIRNAME}/../../src/cert-manager.sh" --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "version" ]]
}

@test "combined flags work correctly" {
    run "${BATS_TEST_DIRNAME}/../../src/cert-manager.sh" --debug --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Debug mode enabled" ]]
    [[ "$output" =~ "version" ]]
}

@test "invalid flag returns error" {
    run "${BATS_TEST_DIRNAME}/../../src/cert-manager.sh" --invalid-flag
    [ "$status" -ne 0 ]
}

@test "double dash stops flag processing" {
    run "${BATS_TEST_DIRNAME}/../../src/cert-manager.sh" -- --help
    [ "$status" -ne 0 ]
    [[ ! "$output" =~ "Usage:" ]]
}
