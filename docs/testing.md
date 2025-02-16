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

### Test Structure

```
test/
├── 00-verify-setup.bats     # Environment verification
├── test_helper.bash         # Common test functions
├── fixtures/               # Test data
└── unit/                  # Unit tests
```

### Writing Tests

Tests use Homebrew's BATS installation:

```bash
#!/usr/bin/env bats

# Load test helper
load 'test_helper'

@test "example test" {
    run some-command
    assert_success
    assert_output "expected output"
}
```

For detailed test plan, see [test-plan.md](test-plan.md)
