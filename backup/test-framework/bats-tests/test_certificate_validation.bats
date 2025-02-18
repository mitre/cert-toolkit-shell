#!/usr/bin/env bats

load test_helper

setup() {
    # Create test directory structure
    TEST_DIR="${TEST_TEMP}/certs"
    mkdir -p "$TEST_DIR"

    # Generate test certificate
    openssl req -x509 \
        -newkey rsa:2048 \
        -keyout "${TEST_DIR}/key.pem" \
        -out "${TEST_DIR}/valid.pem" \
        -days 1 \
        -nodes \
        -subj "/CN=test"

    # Source the script under test
    source "${PROJECT_ROOT}/src/cert-manager.sh"

    if [[ "${DEBUG:-}" == "true" ]]; then
        echo "Test setup complete. Certificate at: ${TEST_DIR}/valid.pem" >&3
    fi
}

teardown() {
    if [[ -d "${TEST_TEMP}" ]]; then
        rm -rf "${TEST_TEMP}"
    fi
}

@test "verify_certificate accepts valid certificate" {
    run verify_certificate "${TEST_DIR}/valid.pem"
    [ "$status" -eq 0 ]
}

@test "verify_certificate rejects invalid certificate" {
    echo "invalid" >"${TEST_DIR}/invalid.pem"
    run verify_certificate "${TEST_DIR}/invalid.pem"
    [ "$status" -eq 1 ]
}
