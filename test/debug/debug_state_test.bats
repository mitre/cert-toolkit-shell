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
    source "${LIB_DIR}/config.sh"
}

teardown() {
    unset DEBUG CERT_TOOLKIT_DEBUG
}

@test "debug state initialization order is correct" {
    export CERT_TOOLKIT_DEBUG=true
    source "${BATS_TEST_DIRNAME}/../../src/lib/debug.sh"
    [ "${DEBUG:-}" = "true" ]
    [ "${CERT_TOOLKIT_DEBUG:-}" = "true" ]
    source "${BATS_TEST_DIRNAME}/../../src/lib/config.sh"
    [ "$(get_config DEBUG)" = "true" ]
}

@test "debug flag takes precedence over environment" {
    export CERT_TOOLKIT_DEBUG=false
    run "${BATS_TEST_DIRNAME}/../../src/cert-manager.sh" --debug
    [ "$status" -eq 0 ]
    [ "$(get_config DEBUG)" = "true" ]
}

@test "debug state persists through configuration updates" {
    export DEBUG=true
    source "${BATS_TEST_DIRNAME}/../../src/lib/config.sh"
    run set_config "CERT_DIR" "/tmp/test"
    [ "$status" -eq 0 ]
    [ "$(get_config DEBUG)" = "true" ]
}

@test "debug environment variables sync correctly" {
    export DEBUG=true
    source "${BATS_TEST_DIRNAME}/../../src/lib/debug.sh"
    [ "${CERT_TOOLKIT_DEBUG:-}" = "true" ]
    unset DEBUG
    export CERT_TOOLKIT_DEBUG=true
    source "${BATS_TEST_DIRNAME}/../../src/lib/debug.sh"
    [ "${DEBUG:-}" = "true" ]
}

@test "debug state survives module reinitialization" {
    export DEBUG=true
    source "${BATS_TEST_DIRNAME}/../../src/lib/core.sh"
    source "${BATS_TEST_DIRNAME}/../../src/lib/config.sh"
    source "${BATS_TEST_DIRNAME}/../../src/lib/debug.sh"
    [ "$(get_config DEBUG)" = "true" ]
    init_config
    [ "$(get_config DEBUG)" = "true" ]
}
