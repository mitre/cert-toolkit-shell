#!/usr/bin/env bats

load ../../helper/load

setup() {
    # Debug setup state
    debug "PATH" "$PATH"
    debug "PWD" "$(pwd)"
    debug "PROJECT_ROOT" "$PROJECT_ROOT"

    # Ensure cert-manager.sh is in path
    PATH="$PROJECT_ROOT/src:$PATH"
    debug "Updated PATH" "$PATH"

    # Verify script exists and is executable
    if [[ ! -x "$PROJECT_ROOT/src/cert-manager.sh" ]]; then
        fail "cert-manager.sh not found or not executable"
    fi
    debug "cert-manager.sh" "$(which cert-manager.sh)"
    debug "cert-manager.sh perms" "$(ls -l $(which cert-manager.sh))"
}

@test "verify command validates PEM certificate" {
    local cert="test/fixtures/certs/mitre-ca-bundle.pem"

    # Debug certificate state
    debug "Certificate exists" "$(test -f "$cert" && echo "yes" || echo "no")"
    debug "Certificate path" "$(readlink -f "$cert")"
    debug "Certificate perms" "$(ls -l "$cert")"
    debug "Certificate type" "$(file "$cert")"

    # Try to validate with OpenSSL directly
    if openssl x509 -noout -in "$cert" 2>/dev/null; then
        debug "OpenSSL" "Certificate is valid"
    else
        debug "OpenSSL" "Certificate validation failed"
    fi

    run_with_debug cert-manager.sh verify "$cert"
    assert_success
}

@test "verify command rejects invalid PEM" {
    run_with_debug cert-manager.sh verify "test/fixtures/certs/invalid/bad_cert.pem"
    assert_failure
    assert_output "invalid certificate: test/fixtures/certs/invalid/bad_cert.pem"
}

@test "verify command handles missing PEM file" {
    run_with_debug cert-manager.sh verify "test/fixtures/certs/nonexistent.pem"
    assert_failure
    assert_output "Certificate file not found: test/fixtures/certs/nonexistent.pem"
}

@test "verify command handles empty PEM file" {
    # Create empty file in invalid directory
    touch "test/fixtures/certs/invalid/empty.pem"

    run_with_debug cert-manager.sh verify "test/fixtures/certs/invalid/empty.pem"
    assert_failure
    assert_output "Empty certificate file: test/fixtures/certs/invalid/empty.pem"
}
