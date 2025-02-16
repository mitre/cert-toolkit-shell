#!/usr/bin/env bash

# OS-specific setup
setup_os_env() {
    case "$(uname -s)" in
    Linux*)
        export CERT_PATH="/etc/ssl/certs"
        export CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
        export UPDATE_COMMAND="update-ca-certificates"
        ;;
    Darwin*)
        export CERT_PATH="/etc/ssl/certs"
        export CA_BUNDLE="/etc/ssl/cert.pem"
        export UPDATE_COMMAND="security add-trusted-cert"
        ;;
    esac
}

# Certificate test helpers
make_test_cert() {
    local name=$1
    local type=${2:-"pem"}
    local dir="${BATS_TEST_TMPDIR}/certs"
    mkdir -p "$dir"

    case "$type" in
    pem) create_pem_cert "$dir/$name.pem" ;;
    der) create_der_cert "$dir/$name.der" ;;
    p7b) create_pkcs7_cert "$dir/$name.p7b" ;;
    esac
}

# Mock system commands
mock_system_commands() {
    local tmpbin="${BATS_TEST_TMPDIR}/bin"
    mkdir -p "$tmpbin"
    PATH="$tmpbin:$PATH"
}
