# Testing Guide

## Test Environment

The project uses `bats-core` as the testing framework with the following components:

- `bats-core`: Main testing framework
- `bats-support`: Support library
- `bats-assert`: Assertions library
- `bats-file`: Filesystem testing library

### macOS Setup

The setup script handles all dependencies through Homebrew:

```bash
./scripts/setup-dev.sh
```

This installs and configures:

- bats-core and libraries
- GNU tools (sed, date, etc.)
- OpenSSL 3.x

### Verify Installation

```bash
# Run verification test
bats test/00-verify-setup.bats

# Run all tests
bats test/
```

## Test Structure

```
test/
├── 00-verify-setup.bats     # Environment verification
├── test_helper.bash         # Common test functions
├── fixtures/               # Test data
└── unit/                  # Unit tests
```

# Testing Framework Documentation

## Overview

The cert-toolkit testing framework uses BATS (Bash Automated Testing System) and follows these key principles:

- Independent test cases
- Consistent environment setup
- Standard error handling
- Comprehensive coverage

## Test Structure

```
test/
├── test_helper.bats          # Common test functions
├── fixtures/                 # Test data
│   ├── certs/               # Test certificates
│   └── configs/             # Test configurations
├── menu/                    # UI tests
│   ├── basic_command_test.bats
│   ├── config_command_test.bats
│   └── menu_test.bats
├── core/                    # Core functionality tests
│   ├── exit_test.bats
│   ├── error_test.bats
│   └── option_test.bats
└── integration/             # End-to-end tests
    └── workflow_test.bats
```

## Writing Tests

### Test File Template

```bash
#!/usr/bin/env bats

# Description of test category
# Key aspects being tested
# Special requirements

load '../test_helper'

setup() {
    # Load required modules
    source "${LIB_DIR}/utils.sh"
    # ... additional modules
}

teardown() {
    # Clean up environment
    unset DEBUG CERT_TOOLKIT_DEBUG
}

@test "descriptive test name" {
    # Test implementation
}
```

### Best Practices

1. One assertion per test
2. Clear test descriptions
3. Proper setup/teardown
4. Error message verification
5. State validation

## Test Categories

### 1. Unit Tests

- Test single functions
- Isolate dependencies
- Verify edge cases
- Check error handling

### 2. Integration Tests

- Test module interactions
- Verify state management
- Check command flow
- Validate output formats

### 3. System Tests

- Full workflow testing
- Real certificate processing
- Performance validation
- Error recovery

## Running Tests

### Basic Usage

```bash
# Run all tests
bats test/

# Run specific test file
bats test/menu/basic_command_test.bats

# Run with debug output
DEBUG=true bats test/menu/basic_command_test.bats
```

### Test Container

```bash
# Build test container
./test/docker/build.sh

# Run tests in container
./test/docker/run-container-tests.sh
```

## Test Helper Functions

### Environment Management

```bash
# Create test certificate
create_test_cert "test-cert" "$CERT_DIR"

# Create test configuration
create_test_config "config" "key=value"

# Skip tests conditionally
skip_if_no_openssl
skip_if_no_curl
skip_if_root
```

### Assertions

```bash
# Standard assertions
assert_success
assert_failure
assert_output
assert_line

# Custom assertions
assert_valid_cert
assert_config_value
assert_debug_state
```

## Debugging Tests

### Debug Output

```bash
# Enable debug mode
DEBUG=true bats test/file.bats

# Show test timing
bats -t test/file.bats

# Print test names
bats test/file.bats -t
```

### Common Issues

1. Environment contamination
2. Module loading order
3. Missing dependencies
4. File permissions

## Test Coverage

### Required Coverage

1. Command processing
2. Flag handling
3. Error conditions
4. State management
5. Certificate operations

### Coverage Report

```bash
# Generate coverage report
./test/coverage.sh

# View report
cat coverage/report.txt
```

## Adding New Tests

1. Create test file in appropriate directory
2. Follow naming convention: `*_test.bats`
3. Include test_helper.bats
4. Add setup/teardown
5. Write clear test cases
6. Verify with debug mode

## Related Documentation

- [DEBUG.md](DEBUG.md): Debug system details
- [ARCHITECTURE.md](ARCHITECTURE.md): System design
- [STANDARDS.md](STANDARDS.md): Coding standards
