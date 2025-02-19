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

    TEST_CONFIG_FILE="$TEST_TEMP_DIR/test_config"
}

teardown() {
    unset DEBUG CERT_TOOLKIT_DEBUG CERT_TOOLKIT_CONFIG
    rm -f "$TEST_CONFIG_FILE"
}

@test "config initialization loads defaults" {
    run init_config
    [ "$status" -eq 0 ]
    [ "$(get_config DEBUG)" = "false" ]
    [ "$(get_config PROCESS_CA_CERTS)" = "true" ]
    [ "$(get_config PROCESS_DOD_CERTS)" = "true" ]
}

@test "environment variables override defaults" {
    export CERT_TOOLKIT_DEBUG=true
    export CERT_TOOLKIT_CERT_DIR=/custom/path

    source "${BATS_TEST_DIRNAME}/../../src/lib/config.sh"
    run init_config

    [ "$(get_config DEBUG)" = "true" ]
    [ "$(get_config CERT_DIR)" = "/custom/path" ]
}

@test "config file overrides environment" {
    echo 'CONFIG[CERT_DIR]=/config/path' >"$TEST_CONFIG_FILE"
    export CERT_TOOLKIT_CERT_DIR=/env/path

    run init_config "$TEST_CONFIG_FILE"
    [ "$(get_config CERT_DIR)" = "/config/path" ]
}

@test "set_config validates input" {
    run set_config "" "value"
    [ "$status" -eq 2 ]

    run set_config "INVALID_KEY" "value"
    [ "$status" -eq 2 ]

    run set_config "DEBUG" "true"
    [ "$status" -eq 0 ]
    [ "$DEBUG" = "true" ]
    [ "$CERT_TOOLKIT_DEBUG" = "true" ]
}

@test "validate_config checks required values" {
    CONFIG[DOD_CERT_URL]=""
    run validate_config
    [ "$status" -ne 0 ]

    CONFIG[DOD_CERT_URL]="https://example.com"
    CONFIG[CERT_DIR]="/nonexistent"
    run validate_config
    [ "$status" -ne 0 ]
}

@test "config update from args processes flags" {
    run update_config_from_args -c -d -o
    [ "$status" -eq 0 ]
    [ "$(get_config PROCESS_CA_CERTS)" = "false" ]
    [ "$(get_config PROCESS_DOD_CERTS)" = "false" ]
    [ "$(get_config PROCESS_ORG_CERTS)" = "false" ]
}
