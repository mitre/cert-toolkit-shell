#!/usr/bin/env bats

load 'helper/test_helper'
load 'helper/mock_command'

setup() {
    setup_test_env
    load_test_certs
    setup_mock_commands
    setup_openssl_mock
    source "${BATS_TEST_DIRNAME}/../src/cert-manager.sh"
}

teardown() {
    cleanup_test_env
}

# Certificate Validation Tests
@test "verify_certificate accepts valid PEM certificate" {
    run verify_certificate "${FIXTURES_DIR}/certs/valid_pem.crt" true
    [ "$status" -eq 0 ]
    [ "$PEM_CERTS" -eq 1 ]
}

@test "verify_certificate rejects invalid certificate" {
    run verify_certificate "${FIXTURES_DIR}/certs/invalid_cert.pem" true
    [ "$status" -eq 1 ]
    [ "$FAILED_CERTS" -eq 1 ]
}

# Metric Tracking Tests
@test "track_metric updates bundle metrics correctly" {
    run track_metric "dod" "processed" 1
    [ "$status" -eq 0 ]
    [ "${BUNDLE_METRICS[dod_processed]}" -eq 1 ]
    [ "$TOTAL_CERTS" -eq 1 ]
}

@test "track_metric handles failed certificates" {
    run track_metric "dod" "failed" 1
    [ "$status" -eq 0 ]
    [ "${BUNDLE_METRICS[dod_failed]}" -eq 1 ]
    [ "$FAILED_CERTS" -eq 1 ]
}

# Error Handling Tests
@test "verify_certificate handles missing file" {
    run verify_certificate "nonexistent.pem" true
    [ "$status" -eq 1 ]
    [ "$SKIPPED_CERTS" -eq 1 ]
}

@test "verify_certificate handles empty file" {
    touch "${TEST_DIR}/empty.pem"
    run verify_certificate "${TEST_DIR}/empty.pem" true
    [ "$status" -eq 1 ]
    [ "$SKIPPED_CERTS" -eq 1 ]
}
