# Test Environment Guide

## Environment Variables

Essential test environment variables:

```bash
TEST_ROOT      # Root of test directory
PROJECT_ROOT   # Root of project
TEST_FIXTURES  # Test fixtures directory
TEST_TEMP      # Temporary test directory
```

## Debug Output

Enable debug output with:

```bash
DEBUG=true bats test/*.bats
```

Debug output format:

```
# Test Paths        : --------
# PROJECT_ROOT      : /path/to/project
# TEST_ROOT        : /path/to/test
# TEST_FIXTURES    : /path/to/fixtures
# TEST_TEMP        : /tmp/bats-1234
```

## Directory Structure

```
test/
├── test_helper.bash     # Common test functions
├── fixtures/           # Test data
│   └── certs/         # Test certificates
├── unit/              # Unit tests
└── integration/       # Integration tests
```

## Writing Tests

Basic test structure:

```bash
#!/usr/bin/env bats

load 'test_helper'

@test "example test" {
    # Setup specific to this test
    local input="${TEST_FIXTURES}/sample.txt"
    
    # Run command
    run some-command "$input"
    
    # Assert results
    assert_success
    assert_output "expected output"
}
```

## Test Helper Functions

Common helper functions:

- `setup_test_environment`: Creates required directories
- `debug "Label" "Value"`: Outputs debug information
- `setup`: Called before each test
- `teardown`: Cleanup after each test
