#!/usr/bin/env bats

load 'helper/test_helper'
load 'helper/mock_command'

setup() {
    setup_test_env
    load_test_certs
    # Source the main script to test internal functions
    source "${BATS_TEST_DIRNAME}/../src/cert-manager.sh"
}

teardown() {
    cleanup_test_env
}

# Individual function tests
@test "verify_certificate handles PEM format" {
    create_test_cert "valid_pem"
    run verify_certificate "$TEST_DIR/certs/valid_pem.pem" true
    [ "$status" -eq 0 ]
    [ "$PEM_CERTS" -eq 1 ]
}

@test "verify_certificate handles DER format" {
    cp "${FIXTURES_DIR}/certs/test_der.crt" "$TEST_DIR/certs/test.der"
    run verify_certificate "$TEST_DIR/certs/test.der" true
    [ "$status" -eq 0 ]
    [ "$DER_CERTS" -eq 1 ]
}

@test "track_metric updates bundle metrics correctly" {
    run track_metric "dod" "processed" 1
    [ "$status" -eq 0 ]
    [ "${BUNDLE_METRICS[dod_processed]}" -eq 1 ]
}
