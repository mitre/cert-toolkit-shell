#!/usr/bin/env bats

load 'helper/test_helper'
load 'helper/mock_command'

setup() {
    setup_test_env
    load_test_certs
    setup_mock_commands
}

teardown() {
    cleanup_test_env
}

# Certificate processing tests
@test "process_certificates handles valid PEM bundle" {
    create_test_cert "bundle"
    run process_certificates "$TEST_DIR/certs/bundle.pem" "$TEST_DIR/output" "test"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/output/"*.crt ]
}

@test "process_certificates detects duplicates" {
    create_test_cert "duplicate"
    cp "$TEST_DIR/certs/duplicate.pem" "$TEST_DIR/certs/duplicate_copy.pem"
    run process_certificates "$TEST_DIR/certs/duplicate.pem" "$TEST_DIR/output" "test"
    run process_certificates "$TEST_DIR/certs/duplicate_copy.pem" "$TEST_DIR/output" "test"
    [[ "$output" =~ "Skipping duplicate certificate" ]]
}
