#!/usr/bin/env bats

load 'helper/test_helper'
load 'helper/mock_command'

setup() {
    setup_test_env
    load_test_certs
    # Source just the functions we need for this test
    source "${BATS_TEST_DIRNAME}/../src/cert-manager.sh"
}

teardown() {
    cleanup_test_env
}

@test "verify_certificate accepts valid PEM certificate" {
    run verify_certificate "${FIXTURES_DIR}/certs/valid_pem.crt" true

    # Debug output
    echo "Status: $status"
    echo "Output: $output"
    echo "PEM_CERTS: $PEM_CERTS"

    [ "$status" -eq 0 ]
    [ "$PEM_CERTS" -eq 1 ]
}
