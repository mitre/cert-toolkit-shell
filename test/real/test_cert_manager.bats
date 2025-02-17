#!/usr/bin/env bats

load ../test_helper

setup() {
    # Create temp test directory
    TEST_DIR=$(mktemp -d)
    export TEST_CERT="$TEST_DIR/test.pem"

    # Generate real test certificate
    openssl req -x509 \
        -newkey rsa:2048 \
        -keyout "$TEST_DIR/key.pem" \
        -out "$TEST_CERT" \
        -days 1 \
        -nodes \
        -subj "/CN=test"

    debug "Created test certificate at: $TEST_CERT"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "verify_certificate accepts valid certificate" {
    run verify_certificate "$TEST_CERT"
    [ "$status" -eq 0 ]
}

@test "verify_certificate rejects invalid certificate" {
    echo "invalid" >"$TEST_DIR/invalid.pem"
    run verify_certificate "$TEST_DIR/invalid.pem"
    [ "$status" -eq 1 ]
}

@test "verify_certificate handles missing file" {
    run verify_certificate "$TEST_DIR/nonexistent.pem"
    [ "$status" -eq 1 ]
}

@test "verify_certificate handles empty file" {
    touch "$TEST_DIR/empty.pem"
    run verify_certificate "$TEST_DIR/empty.pem"
    [ "$status" -eq 1 ]
}
