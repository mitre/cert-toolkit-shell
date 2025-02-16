#!/usr/bin/env bash

# Setup test environment
setup_test_env() {
    TEST_DIR="$(mktemp -d)"
    FIXTURES_DIR="${BATS_TEST_DIRNAME}/../fixtures"
    MOCK_DIR="${TEST_DIR}/mock_bin"
    export TEST_DIR FIXTURES_DIR MOCK_DIR
    mkdir -p "${MOCK_DIR}"
    export PATH="${MOCK_DIR}:$PATH"
}

# Cleanup test environment
cleanup_test_env() {
    rm -rf "${TEST_DIR}"
}

# Load test certificates
load_test_certs() {
    mkdir -p "${TEST_DIR}/certs"
    cp "${FIXTURES_DIR}/certs/"* "${TEST_DIR}/certs/"
}

# Create a test certificate
create_test_cert() {
    local name=$1
    local dir="${TEST_DIR}/certs"
    mkdir -p "$dir"
    cat >"${dir}/${name}.pem" <<EOF
-----BEGIN CERTIFICATE-----
MIIDTestCertificateForTestingPurposesOnly
ThisIsNotARealCertificateAndShouldOnly
BeUsedForTestingTheCertToolkitShell
-----END CERTIFICATE-----
EOF
}

# Add to existing test_helper.bash
setup_mock_openssl() {
    cat >"${MOCK_DIR}/openssl" <<'EOF'
#!/bin/bash
case "$1" in
    "x509")
        case "$2" in
            "-noout") handle_x509_noout "$@" ;;
            "-inform") handle_x509_inform "$@" ;;
        esac
        ;;
    "pkcs7")
        handle_pkcs7 "$@"
        ;;
esac
EOF
    chmod +x "${MOCK_DIR}/openssl"
}

setup_mock_curl() {
    cat >"${MOCK_DIR}/curl" <<'EOF'
#!/bin/bash
if [[ "$*" =~ "fail" ]]; then
    exit 1
fi
echo "Mock response"
exit 0
EOF
    chmod +x "${MOCK_DIR}/curl"
}
