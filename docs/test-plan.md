# Testing Plan

## Phase 1: Core Function Testing

### Critical Path Tests (Priority 1)

1. Certificate Validation

```bash
@test "verify_certificate validates valid PEM certificate"
@test "verify_certificate rejects invalid certificate"
@test "verify_certificate handles DER format conversion"
@test "verify_certificate handles PKCS7 format conversion"
```

2. Certificate Processing

```bash
@test "process_certificates successfully installs certificate"
@test "process_certificates detects and handles duplicates"
@test "process_certificates maintains proper permissions"
```

3. Metric Tracking

```bash
@test "track_metric correctly updates bundle counts"
@test "track_metric handles multiple certificate types"
@test "track_metric maintains accurate totals"
```

### Support Function Tests (Priority 2)

```bash
@test "find_ca_cert_file locates system certificates"
@test "is_package_installed correctly detects packages"
@test "install_package handles different package managers"
```

## Phase 2: Integration Testing

### Bundle Processing (Priority 3)

```bash
@test "process_dod_certs downloads and extracts bundle"
@test "process_org_certs handles combined PEM file"
@test "process_ca_certificates processes system certificates"
```

### System Integration (Priority 4)

```bash
@test "update_ca_certificates updates system store"
@test "certificate installations persist across reboots"
@test "permissions are correctly maintained"
```

## Required Test Fixtures

### Certificate Fixtures

```
test/fixtures/certs/
├── valid_pem.crt          # Standard PEM certificate
├── valid_der.crt          # DER formatted certificate
├── valid_pkcs7.p7b        # PKCS7 bundle
├── invalid_cert.pem       # Malformed certificate
├── expired_cert.pem       # Expired certificate
└── duplicate_cert.pem     # Duplicate of valid_pem.crt
```

### Mock Commands

```bash
test/helper/mock_command.bash
└── Functions
    ├── mock_openssl       # Certificate operations
    ├── mock_curl         # Network operations
    └── mock_system       # System commands
```

## Implementation Checklist

### Phase 1 Tasks

- [ ] Create base test fixtures
- [ ] Implement mock_command.bash
- [ ] Write core function tests
- [ ] Add error handling tests

### Phase 2 Tasks

- [ ] Add integration test fixtures
- [ ] Implement system mocks
- [ ] Write bundle processing tests
- [ ] Add system integration tests

## Test Execution

### Local Development

```bash
# Run all tests
bats test/*.bats

# Run specific test suite
bats test/test_functions.bats
bats test/test_certificate_processing.bats

# Run with debug output
DEBUG=true bats test/*.bats
```

### CI/CD Pipeline

```yaml
- name: Run unit tests
  run: bats test/test_*.bats

- name: Run integration tests
  run: bats test/integration/*.bats
```

## Success Criteria

1. All core functions have >90% test coverage
2. All error conditions are tested
3. Integration tests pass on all supported platforms
4. No regressions in existing functionality
5. All tests are properly documented
