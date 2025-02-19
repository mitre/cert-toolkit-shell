# Testing Certificate Management Functions

## Test Organization

```bash
test/
├── unit/
│   ├── test_cert_validation.bats    # Certificate validation tests
│   ├── test_cert_conversion.bats    # Format conversion tests
│   └── test_cert_installation.bats  # Installation tests
├── integration/
│   ├── test_dod_certs.bats         # DoD certificate processing
│   ├── test_org_certs.bats         # Organization certificate processing
│   └── test_system_store.bats      # System store integration
└── fixtures/
    └── certs/
        ├── valid/                   # Valid certificates
        ├── invalid/                # Invalid certificates
        └── formats/                # Different format certificates
```

## Setting Up Test Fixtures

```bash
# Create test certificate
openssl req -x509 -newkey rsa:2048 -keyout test/fixtures/certs/valid/key.pem \
    -out test/fixtures/certs/valid/cert.pem -days 1 -nodes \
    -subj "/CN=Test Certificate"

# Create different formats
openssl x509 -in test/fixtures/certs/valid/cert.pem \
    -out test/fixtures/certs/formats/cert.der -outform DER
```

## Testing Certificate Validation

```bash
#!/usr/bin/env bats

load '../test_helper'

@test "verify_certificate accepts valid PEM" {
    run verify_certificate "${TEST_FIXTURES}/certs/valid/cert.pem"
    assert_success
}

@test "verify_certificate rejects invalid certificate" {
    run verify_certificate "${TEST_FIXTURES}/certs/invalid/bad.pem"
    assert_failure
    assert_output --partial "invalid certificate"
}

@test "verify_certificate converts DER to PEM" {
    local der_cert="${TEST_FIXTURES}/certs/formats/cert.der"
    local pem_cert="${TEST_TEMP}/converted.pem"
    
    run verify_certificate "$der_cert" "$pem_cert"
    assert_success
    
    # Verify conversion
    run openssl x509 -in "$pem_cert" -noout
    assert_success
}
```

## Testing Certificate Installation

```bash
#!/usr/bin/env bats

load '../test_helper'

@test "process_certificates installs to correct location" {
    local test_cert="${TEST_FIXTURES}/certs/valid/cert.pem"
    local dest_dir="${TEST_TEMP}/store"
    
    run process_certificates "$test_cert" "$dest_dir"
    assert_success
    assert_dir_exist "$dest_dir"
    assert [ -f "${dest_dir}/Test_Certificate.crt" ]
}

@test "process_certificates maintains correct permissions" {
    local test_cert="${TEST_FIXTURES}/certs/valid/cert.pem"
    local dest_dir="${TEST_TEMP}/store"
    
    run process_certificates "$test_cert" "$dest_dir"
    assert_success
    
    run stat -f "%Lp" "${dest_dir}/Test_Certificate.crt"
    assert_output "644"
}
```

## Testing DoD Certificate Processing

```bash
#!/usr/bin/env bats

load '../test_helper'

@test "process_dod_certs downloads bundle" {
    # Mock wget to return test bundle
    function wget() {
        cp "${TEST_FIXTURES}/certs/bundles/dod.zip" "$2"
    }
    export -f wget
    
    run process_dod_certs
    assert_success
}

@test "process_dod_certs extracts certificates" {
    setup_mock_download
    
    run process_dod_certs
    assert_success
    assert_dir_contain_files "/usr/local/share/ca-certificates" "*.crt"
}
```

## Testing Error Handling

```bash
#!/usr/bin/env bats

load '../test_helper'

@test "handle_download_failure provides meaningful error" {
    # Force download failure
    function wget() { return 1; }
    export -f wget
    
    run process_dod_certs
    assert_failure
    assert_output --partial "Failed to download certificate bundle"
}

@test "handle_conversion_failure provides debug info" {
    DEBUG=true
    run verify_certificate "${TEST_FIXTURES}/certs/invalid/truncated.der"
    assert_failure
    assert_output --partial "Failed to convert DER to PEM"
}
```

## Testing System Integration

```bash
#!/usr/bin/env bats

load '../test_helper'

@test "certificates persist across update-ca-certificates" {
    local test_cert="${TEST_FIXTURES}/certs/valid/cert.pem"
    
    # Install certificate
    run process_certificates "$test_cert" "/usr/local/share/ca-certificates"
    assert_success
    
    # Update system store
    run update_ca_certificates
    assert_success
    
    # Verify certificate is in system store
    run openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt \
        "$test_cert"
    assert_success
}
```

## Mocking System Commands

```bash
# Mock system commands in test_helper.bash

setup() {
    # Original setup code...
    
    # Mock system commands
    export PATH="${TEST_ROOT}/mocks:$PATH"
}

# In test/mocks/update-ca-certificates:
#!/bin/bash
echo "Updating certificates..."
exit 0
```

## Test Helpers for Certificate Testing

```bash
# Add to test_helper.bash

# Create a test certificate
create_test_cert() {
    local name=$1
    local days=${2:-1}
    local out_dir="${TEST_TEMP}/certs"
    
    mkdir -p "$out_dir"
    openssl req -x509 -newkey rsa:2048 -keyout "${out_dir}/${name}.key" \
        -out "${out_dir}/${name}.pem" -days "$days" -nodes \
        -subj "/CN=${name}"
}

# Convert certificate format
convert_cert_format() {
    local input=$1
    local output=$2
    local format=${3:-DER}
    
    openssl x509 -in "$input" -out "$output" -outform "$format"
}
```

## Running Certificate Tests

```bash
# Run all certificate tests
bats test/unit/test_cert_*.bats

# Run with debug output
DEBUG=true bats test/unit/test_cert_validation.bats

# Run integration tests
sudo bats test/integration/*.bats
```

For more details on specific test scenarios, see [test-cases.md](test-cases.md)
