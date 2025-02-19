#!/bin/bash

# Directory structure
FIXTURES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTS_DIR="$FIXTURES_DIR/certs"
mkdir -p "$CERTS_DIR"/{valid,invalid,formats}

# Generate valid test certificates
generate_valid_certs() {
    local dir="$CERTS_DIR/valid"

    # Standard PEM certificate
    openssl req -x509 -newkey rsa:2048 -keyout "$dir/test.key" \
        -out "$dir/test.pem" -days 365 -nodes \
        -subj "/C=US/ST=MA/L=Bedford/O=MITRE/CN=test.mitre.org"

    # Certificate chain
    openssl req -x509 -newkey rsa:2048 -keyout "$dir/root.key" \
        -out "$dir/root.pem" -days 365 -nodes \
        -subj "/C=US/ST=MA/L=Bedford/O=MITRE/CN=root.mitre.org"
}

# Generate invalid certificates
generate_invalid_certs() {
    local dir="$CERTS_DIR/invalid"

    # Empty file
    touch "$dir/empty.pem"

    # Invalid format
    echo "invalid content" >"$dir/bad_format.pem"

    # Expired certificate
    openssl req -x509 -newkey rsa:2048 -keyout "$dir/expired.key" \
        -out "$dir/expired.pem" -days -365 -nodes \
        -subj "/C=US/ST=MA/L=Bedford/O=MITRE/CN=expired.mitre.org"
}

# Generate different format certificates
generate_format_certs() {
    local dir="$CERTS_DIR/formats"

    # Generate PEM certificate
    openssl req -x509 -newkey rsa:2048 -keyout "$dir/cert.key" \
        -out "$dir/cert.pem" -days 365 -nodes \
        -subj "/C=US/ST=MA/L=Bedford/O=MITRE/CN=format.mitre.org"

    # Convert to DER
    openssl x509 -in "$dir/cert.pem" -outform der -out "$dir/cert.der"

    # Create PKCS7 bundle
    openssl crl2pkcs7 -nocrl -certfile "$dir/cert.pem" -out "$dir/cert.p7b"
}

# Generate all test certificates
generate_valid_certs
generate_invalid_certs
generate_format_certs

echo "Test certificates generated in: $CERTS_DIR"
