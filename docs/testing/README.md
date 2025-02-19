# Testing Documentation

## Overview

The cert-toolkit testing framework provides comprehensive test coverage using BATS (Bash Automated Testing System).

## Test Documentation Structure

1. [Framework Overview](framework.md)
   - Test environment setup
   - Helper functions
   - Common patterns
   - Best practices

2. [Writing Tests](writing-tests.md)
   - Test file structure
   - Test case patterns
   - State management
   - Error testing

3. [Test Categories](categories.md)
   - Unit tests
   - Integration tests
   - System tests
   - Performance tests

4. [Container Testing](container.md)
   - Container setup
   - Running tests
   - Debug mode
   - Test isolation

## Setup

For development environment setup, see [Setup Guide](../dev/setup.md).

## Quick Start

```bash
# Run all tests
bats test/

# Run specific test category
bats test/menu/

# Run with debug output
DEBUG=true bats test/
```

## Test Organization

```
test/
├── test_helper.bats     # Common functions
├── core/               # Core functionality
├── menu/              # Menu system
├── integration/       # Cross-module tests
└── fixtures/         # Test data
```

## Related Documentation

- [Coding Standards](../standards/coding.md)   # Fixed relative path
- [Debug System](../tech/debug.md)            # Fixed from DEBUG.md
- [Architecture](../dev/architecture.md)       # Fixed from ARCHITECTURE.md
