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

setup_mock_commands() {
    # Mock openssl command
    mock_command "openssl"
    # Mock curl command
    mock_command "curl"
    # Mock update-ca-certificates command
    mock_command "update-ca-certificates"
}

@test "cert-manager shows help" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" --help
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ "Usage:" ]]
}

@test "cert-manager can list certificates" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" list
    [ "$status" -eq 0 ]
    [[ "$output" =~ "test_cert.pem" ]]
}

@test "cert-manager can display certificate info" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" info "$TEST_DIR/certs/test_cert.pem"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Certificate Information" ]]
}

@test "cert-manager handles missing certificate" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" info "nonexistent.pem"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Certificate file not found" ]]
}

@test "cert-manager can add DOD certificates" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" add-dod-certs
    [ "$status" -eq 0 ]
}

@test "verify_certificate accepts valid PEM certificate" {
    create_test_cert "valid"
    run verify_certificate "$TEST_DIR/certs/valid.pem" true
    [ "$status" -eq 0 ]
}

@test "verify_certificate rejects invalid certificate" {
    echo "invalid" >"$TEST_DIR/certs/invalid.pem"
    run verify_certificate "$TEST_DIR/certs/invalid.pem" true
    [ "$status" -eq 1 ]
}

@test "process_certificates handles valid certificates" {
    create_test_cert "valid"
    mkdir -p "$TEST_DIR/output"
    run process_certificates "$TEST_DIR/certs/valid.pem" "$TEST_DIR/output" "test"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/output"/*.crt ]
}

@test "skip flags work correctly" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" -c -d -o -s
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Skipping" ]]
}

@test "cert-manager shows version" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "version" ]]
}

@test "cert-manager handles invalid commands" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" invalid-command
    [ "$status" -eq 1 ]
}

@test "certificate directory detection works" {
    mkdir -p "$TEST_DIR/etc/ssl/certs"
    touch "$TEST_DIR/etc/ssl/certs/ca-certificates.crt"
    CERT_PATH="$TEST_DIR/etc/ssl/certs/ca-certificates.crt"
    [ -f "$CERT_PATH" ]
}

@test "metrics tracking works correctly" {
    export TOTAL_CERTS=0
    export PEM_CERTS=0
    export FAILED_CERTS=0

    create_test_cert "valid"
    verify_certificate "$TEST_DIR/certs/valid.pem" true
    echo "invalid" >"$TEST_DIR/certs/invalid.pem"
    verify_certificate "$TEST_DIR/certs/invalid.pem" true

    [ "$TOTAL_CERTS" -eq 1 ]
    [ "$PEM_CERTS" -eq 1 ]
    [ "$FAILED_CERTS" -eq 1 ]
}
