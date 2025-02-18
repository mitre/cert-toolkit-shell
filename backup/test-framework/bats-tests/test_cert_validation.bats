#!/usr/bin/env bats

load '../test_helper'
load '../lib/mock_helper'

setup() {
    setup_test_environment
    reset_mocks
}

teardown() {
    reset_mocks
}

# Test valid PEM certificate
@test "verify_certificate accepts valid PEM certificate" {
    # Mock openssl to succeed for valid cert
    mock_command "openssl" "Certificate details" 0

    run verify_certificate "${TEST_FIXTURES}/certs/valid/cert.pem"

    assert_success
    assert_mock_called_with "openssl" "x509" "-noout" "-in" "${TEST_FIXTURES}/certs/valid/cert.pem"
}

# Test invalid certificate
@test "verify_certificate rejects invalid certificate" {
    # Mock openssl to fail for invalid cert
    mock_command "openssl" "unable to load certificate" 1

    run verify_certificate "${TEST_FIXTURES}/certs/invalid/bad.pem"

    assert_failure
    assert_output --partial "invalid certificate"
    assert_mock_called "openssl"
}

# Test DER format conversion
@test "verify_certificate converts DER to PEM" {
    # First mock checks format (fails for PEM)
    mock_command_with_responses "openssl" \
        "x509 -noout -in" "not a PEM certificate" 1 \
        "x509 -inform DER -in" "DER certificate details" 0

    run verify_certificate "${TEST_FIXTURES}/certs/formats/cert.der"

    assert_success
    assert_mock_called_with_pattern "openssl" ".*-inform DER.*"
}

# Test PKCS7 bundle extraction
@test "verify_certificate extracts certificates from PKCS7" {
    # Mock responses for PKCS7 detection and extraction
    mock_command_with_responses "openssl" \
        "x509 -noout" "not a PEM certificate" 1 \
        "pkcs7 -print_certs" "BEGIN CERTIFICATE" 0

    run verify_certificate "${TEST_FIXTURES}/certs/formats/bundle.p7b"

    assert_success
    assert_mock_called_with_pattern "openssl" ".*pkcs7 -print_certs.*"
}
