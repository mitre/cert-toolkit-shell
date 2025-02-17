#!/usr/bin/env bash

# Setup test environment - needed by verify-setup.bats
setup_test_environment() {
    mkdir -p "${TEST_FIXTURES}"
    mkdir -p "${TEST_TEMP}"
    debug "Created test directories"
}

# Create test certificate with proper file handling
create_test_cert() {
    local name=$1
    local days=${2:-1}
    local dir="${TEST_TEMP}/certs"

    mkdir -p "$dir"

    # Create certificate file
    cat >"${dir}/${name}.pem" <<EOF
-----BEGIN CERTIFICATE-----
MIIDvTCCAqWgAwIBAgIUBLxKClPa0g+FyjF+z0CE9Gz3ALwwDQYJKoZIhvcNAQEL
BQAwbTELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAk1BMRIwEAYDVQQHEwlBbl9BcmJv
cjEPMA0GA1UEChMGTUlUUkUyMR4wHAYDVQQLExVDZXJ0aWZpY2F0ZV9NYW5hZ2Vy
czEMMAoGA1UEAxMDQ0EyMB4XDTIzMTIxNjAwMDAwMFoXDTI0MTIxNjAwMDAwMFow
EzERMA8GA1UEAxMIdGVzdF9jZXJ0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
-----END CERTIFICATE-----
EOF

    # Verify file creation
    if [ ! -f "${dir}/${name}.pem" ]; then
        echo "Failed to create certificate file: ${dir}/${name}.pem" >&2
        return 1
    fi

    # Mock openssl for verification
    mock_command "openssl" "Certificate OK" 0

    debug "Created certificate" "${dir}/${name}.pem"
    return 0
}

# Create different certificate formats
convert_cert_format() {
    local input=$1
    local output=$2
    local format=${3:-DER}
    local dir

    dir=$(dirname "$output")
    mkdir -p "$dir"

    # Create a proper binary DER file
    printf '\x30\x82\x03\x90\x30\x82\x02\x78\xA0\x03\x02\x01\x02\x02\x14' >"$output"
    dd if=/dev/urandom bs=1 count=100 >>"$output" 2>/dev/null

    # Clear any existing mocks
    reset_mocks

    # Set up new mock responses for DER testing
    mock_command_with_responses "openssl" \
        "x509 -noout -in.*" "not a PEM certificate" 1 \
        "x509 -inform der -noout.*" "Certificate: OK" 0 \
        "x509 -inform DER -noout.*" "Certificate: OK" 0 \
        "x509 -inform der.*" "Certificate: OK" 0 \
        "x509 -inform DER.*" "Certificate: OK" 0

    debug_der_operation "$output" "convert"
    return 0
}

# Setup test certificate directory
setup_test_certs() {
    local cert_dir="${TEST_TEMP}/certs"
    mkdir -p "$cert_dir"

    # Copy fixtures if they exist
    if [[ -d "${TEST_FIXTURES}/certs" ]]; then
        cp -r "${TEST_FIXTURES}/certs/"* "$cert_dir/" 2>/dev/null || true
    fi

    # Create basic test cert if none exist
    if [[ ! -f "$cert_dir/test_cert.pem" ]]; then
        create_test_cert "test_cert"
    fi
}

create_test_bundle() {
    local output="${TEST_FIXTURES}/certs/formats"
    mkdir -p "$output"

    # Create test PKCS7 bundle
    cat >"${output}/bundle.p7b" <<EOF
-----BEGIN PKCS7-----
MIIHzgYJKoZIhvcNAQcCoIIHvzCCB7sCAQExCzAJBgUrDgMCGgUAMIIBJAYJKoZI
hvcNAQcBoIIBFQSCAREwggEMMIIBBgKCAQEA1234567890ABCDEFGHIJKLMNOPQRS
-----END PKCS7-----
EOF

    # Setup mock for PKCS7 testing
    mock_command_with_responses "openssl" \
        "pkcs7 -print_certs.*" "-----BEGIN CERTIFICATE-----\nMIIDvTCCAqWgAwIBAgIUBLx...\n-----END CERTIFICATE-----" 0
}

# Create invalid certificate
create_invalid_cert() {
    local name=$1
    local dir="${TEST_TEMP}/certs"
    mkdir -p "$dir"
    echo "Invalid Certificate Content" >"${dir}/${name}.pem"
}

# Assert directory contains certificates
assert_has_certs() {
    local dir=$1
    local count=0

    if [[ ! -d "$dir" ]]; then
        echo "Directory $dir does not exist"
        return 1
    fi

    count=$(find "$dir" -name "*.crt" -o -name "*.pem" | wc -l)
    if [[ $count -eq 0 ]]; then
        echo "No certificates found in $dir"
        return 1
    fi
}

# Setup package manager mocks
setup_package_mocks() {
    # Mock package managers
    mock_command_with_responses "command" \
        ".*apt-get.*" "/usr/bin/apt-get" 0 \
        ".*dpkg-query.*" "/usr/bin/dpkg-query" 0 \
        ".*yum.*" "/usr/bin/yum" 0 \
        ".*dnf.*" "/usr/bin/dnf" 0 \
        ".*apk.*" "/sbin/apk" 0

    # Mock package queries
    mock_command_with_responses "dpkg-query" \
        ".*curl.*" "Status: install ok installed" 0 \
        ".*openssl.*" "Status: install ok installed" 0 \
        ".*wget.*" "Status: install ok installed" 0

    # Mock package installation commands
    mock_command "apt-get" "" 0
    mock_command "yum" "" 0
    mock_command "dnf" "" 0
    mock_command "apk" "" 0
}
