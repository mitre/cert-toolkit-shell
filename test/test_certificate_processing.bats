#!/usr/bin/env bats

# Use centralized test helper
load 'test_helper'

setup() {
    setup_test_environment
    setup_mock_tracking

    # Setup test certificates
    setup_test_certs
}

teardown() {
    reset_mocks
    rm -rf "${TEST_TEMP}"
}

@test "process_certificates handles PEM bundle" {
    mock_command "openssl" "OK" 0
    run process_certificates "${TEST_FIXTURES}/certs/valid/test.pem"
    assert_success
}

@test "process_certificates detects duplicates" {
    create_test_cert "duplicate"
    cp "$TEST_DIR/certs/duplicate.pem" "$TEST_DIR/certs/duplicate_copy.pem"
    run process_certificates "$TEST_DIR/certs/duplicate.pem" "$TEST_DIR/output" "test"
    run process_certificates "$TEST_DIR/certs/duplicate_copy.pem" "$TEST_DIR/output" "test"
    [[ "$output" =~ "Skipping duplicate certificate" ]]
}
