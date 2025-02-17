#!/usr/bin/env bats

setup() {
    # Create temp test directory
    TEST_DIR=$(mktemp -d)
    TEST_CERT="$TEST_DIR/test.pem"

    # Generate real test certificate
    openssl req -x509 \
        -newkey rsa:2048 \
        -keyout "$TEST_DIR/key.pem" \
        -out "$TEST_CERT" \
        -days 1 \
        -nodes \
        -subj "/CN=test"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "verify_certificate accepts valid certificate" {
    run ./src/cert-manager.sh verify "$TEST_CERT"
    [ "$status" -eq 0 ]
}

@test "verify_certificate rejects invalid certificate" {
    echo "invalid" >"$TEST_DIR/invalid.pem"
    run ./src/cert-manager.sh verify "$TEST_DIR/invalid.pem"
    [ "$status" -eq 1 ]
}

# More tests...
