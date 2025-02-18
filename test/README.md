# Certificate Manager Test Suite

## Overview

The test suite validates the functionality of cert-manager.sh across different platforms and environments using container-based testing.

## Core Functional Areas

### 1. Certificate Validation

- Format Detection
  - PEM/DER/PKCS7 validation
  - Certificate content verification
  - Date validation
- Key Management
  - RSA/DSA/EC key validation
  - Key format verification
  - Permission handling
- Error Cases
  - Invalid content/Missing files
  - Empty files/Access issues

### 2. Certificate Processing

- Bundle Operations
  - Split certificate bundles
  - Format conversion
  - Chain verification
- Metadata Handling
  - Subject/issuer extraction
  - Naming conventions
  - Duplicate management
- Metrics
  - Counter accuracy
  - Processing statistics

### 3. Source Management

- DoD Certificates
  - Bundle download/extraction
  - Format detection
  - Content validation
- Organization Certificates
  - Static/dynamic list handling
  - Repository integration
  - Combined PEM support
- System Integration
  - CA bundle location
  - Trust chain updates

## Test Organization

### Test Categories

| Priority | Category | Focus Area | Examples |
|----------|----------|------------|----------|
| P0 | Core | Basic certificate operations | Format validation, key verification |
| P1 | Security | Permission and trust | Key protection, secure storage |
| P2 | Integration | System interaction | Store updates, chain building |
| P3 | Platform | OS-specific features | Package management, directories |
| P4 | Edge Cases | Error conditions | Invalid formats, corrupted files |

### Directory Structure

# Test Organization

## Core Features

### 1. Certificate Validation (`validation/`)

- Format Detection Tests (`formats_test.bats`)
  - PEM validation
  - DER validation
  - PKCS7 validation
  - Invalid formats
- Key Validation Tests (`keys_test.bats`)
  - RSA keys
  - DSA keys
  - EC keys
  - Invalid keys
- Error Handling Tests (`errors_test.bats`)
  - Missing files
  - Empty files
  - Permission issues

### 2. Certificate Processing (`processing/`)

- Bundle Processing Tests (`bundle_test.bats`)
  - Certificate splitting
  - Duplicate handling
  - Name generation
- Metadata Tests (`metadata_test.bats`)
  - Subject extraction
  - Date validation
  - Chain validation
- Metrics Tests (`metrics_test.bats`)
  - Counter accuracy
  - Bundle statistics

### 3. Source Management (`sources/`)

- DoD Certificate Tests (`dod_test.bats`)
  - Bundle download
  - Format detection
  - Extraction
- Organization Certificate Tests (`org_test.bats`)
  - Static list
  - Dynamic fetching
  - Combined PEM
- System CA Tests (`system_test.bats`)
  - CA bundle location
  - System integration

### 4. Platform Integration (`platforms/`)

- Package Management Tests (`packages_test.bats`)
  - Dependency checks
  - Installation handling
- OS Detection Tests (`os_test.bats`)
  - Directory locations
  - Update mechanisms
- Certificate Store Tests (`store_test.bats`)
  - Store updates
  - Trust chain

### 5. Output and Reporting (`reporting/`)

- Debug Output Tests (`debug_test.bats`)
  - Verbosity levels
  - Output formatting
- Summary Report Tests (`summary_test.bats`)
  - Statistics accuracy
  - Format handling

## Test Fixtures

test/fixtures/
├── certs/                    # Certificate test files
│   ├── valid/               # Known good certificates
│   │   ├── test.pem        # Valid PEM certificate
│   │   └── test.key        # Valid private key
│   ├── invalid/            # Invalid test cases
│   │   └── bad_cert.pem    # Invalid certificate
│   ├── formats/            # Format test files
│   │   ├── test.der       # DER format
│   │   └── bundle.p7b     # PKCS7 bundle
│   └── mitre-ca-bundle.pem # Real certificate bundle
└── bundles/                 # Certificate bundles
    └── dod.zip             # DoD certificate bundle

## Running Tests

```bash

# Run all tests
./test/docker/run-container-tests.sh

# Run specific test
./test/docker/run-container-tests.sh "test/features/validation/*.bats"

# Run with debug output
DEBUG=true ./test/docker/run-container-tests.sh

# Interactive debug session
./test/docker/run-container-tests.sh shell

```

Platform Testing
Tests run in isolated containers for each platform:

```bash
# Run Ubuntu tests
./test/docker/run-container-tests.sh -p ubuntu

# Run RHEL tests
./test/docker/run-container-tests.sh -p rhel

# Run all tests
./test/docker
```
