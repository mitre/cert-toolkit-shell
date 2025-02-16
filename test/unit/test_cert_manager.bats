#!/usr/bin/env bats

load '../test_helper'
load '../lib/mock_helper'

# Setup test environment before each test
setup() {
    setup_test_environment
    reset_mocks

    # Source the script under test
    source "${PROJECT_ROOT}/src/cert-manager.sh"
}

teardown() {
    reset_mocks
}

# Test certificate validation function
@test "verify_certificate correctly identifies valid PEM" {
    mock_command "openssl" "Certificate details" 0

    run verify_certificate "${TEST_FIXTURES}/certs/valid/cert.pem"

    assert_success
    assert_mock_called "openssl"
}

# Test certificate format detection
@test "verify_certificate detects and converts DER format" {
    mock_command_with_responses "openssl" \
        "x509 -noout -in" "not a PEM certificate" 1 \
        "x509 -inform DER -in" "DER certificate details" 0

    local test_cert="${TEST_FIXTURES}/certs/formats/cert.der"
    run verify_certificate "$test_cert"

    assert_success
    assert_mock_called "openssl" 2
}

# Test certificate metrics tracking
@test "verify_certificate updates metric counters" {
    mock_command "openssl" "Certificate details" 0

    TOTAL_CERTS=0
    PEM_CERTS=0

    run verify_certificate "${TEST_FIXTURES}/certs/valid/cert.pem"

    assert_success
    assert_equal "$TOTAL_CERTS" 1
    assert_equal "$PEM_CERTS" 1
}

# Test certificate installation
@test "process_certificates installs to correct location" {
    local test_cert="${TEST_FIXTURES}/certs/valid/test.pem"
    local dest_dir="${TEST_TEMP}/certs"

    # Mock openssl for certificate subject extraction
    mock_command_with_responses "openssl" \
        "x509 -noout -in" "success" 0 \
        "x509 -noout -subject" "CN = Test Cert" 0

    run process_certificates "$test_cert" "$dest_dir"

    assert_success
    assert_dir_exist "$dest_dir"
}

# Test error handling
@test "verify_certificate handles missing file" {
    run verify_certificate "${TEST_FIXTURES}/certs/nonexistent.pem"

    assert_failure
    assert [ "$SKIPPED_CERTS" -eq 1 ]
}

# Test DoD certificate processing
@test "process_dod_certs downloads and processes bundle" {
    # Mock wget to simulate download
    mock_command "wget" "" 0

    # Mock curl for bundle URL fetch
    mock_command "curl" "<a href='DoD_bundle.zip'>DoD_bundle.zip</a>" 0

    # Mock unzip
    mock_command "unzip" "" 0

    # Mock openssl for certificate extraction
    mock_command_with_responses "openssl" \
        "pkcs7 -print_certs" "BEGIN CERTIFICATE" 0 \
        "x509 -noout" "success" 0

    run process_dod_certs

    assert_success
    assert_mock_called "wget"
    assert_mock_called "unzip"
}

# Test update-ca-certificates handling
@test "update_ca_certificates runs correctly" {
    mock_command "update-ca-certificates" "Updating certificates..." 0

    run update_ca_certificates

    assert_success
    assert_mock_called "update-ca-certificates"
}
