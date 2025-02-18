# Docker-Based Testing Infrastructure

## Overview

The testing infrastructure uses Docker to provide a consistent, isolated testing environment. This ensures tests run the same way across different development environments and CI/CD systems.

## Key Components

### 1. run-container-tests.sh

Main test runner script that:

- Builds test container
- Mounts project code
- Executes BATS tests
- Handles debug state

### 2. ubuntu.Dockerfile

Test container definition that provides:

- Base Ubuntu 22.04 environment
- Required packages (bats, curl, openssl, etc.)
- MITRE CA bundle integration
- BATS test helpers

## Test Pattern Support

The test runner supports various pattern types for flexible test execution:

### 1. Single File

```bash
# Run specific test file
./test/docker/run-container-tests.sh test/debug/debug_test.bats

# Run with debug output
./test/docker/run-container-tests.sh --debug test/debug/debug_state_test.bats
```

### 2. Directory Level Patterns

```bash
# All tests in directory
./test/docker/run-container-tests.sh "test/debug/*.bats"

# Multiple directories
./test/docker/run-container-tests.sh test/debug/*.bats test/core/*.bats

# Pattern matching in directory
./test/docker/run-container-tests.sh "test/debug/debug_*.bats"
```

### 3. Recursive Patterns

```bash
# All tests in project
./test/docker/run-container-tests.sh "test/**/*.bats"

# All debug tests in any directory
./test/docker/run-container-tests.sh "test/**/debug_*.bats"
```

### 4. Combined Patterns

```bash
# Multiple pattern types
./test/docker/run-container-tests.sh "test/debug/*.bats" "test/core/debug_*.bats"

# Recursive and specific
./test/docker/run-container-tests.sh "test/**/*.bats" test/debug/specific_test.bats
```

### 5. Test Group Patterns

```bash
# Any debug tests in any group
./test/docker/run-container-tests.sh "test/*/debug_*.bats"

# All tests in specific groups
./test/docker/run-container-tests.sh "test/{debug,core}/*.bats"
```

## Usage Examples

1. Development Flow

```bash
# Run all tests with debug output
./test/docker/run-container-tests.sh --debug "test/**/*.bats"

# Run specific module tests
./test/docker/run-container-tests.sh "test/debug/*.bats"

# Interactive debugging
./test/docker/run-container-tests.sh shell
```

2. Debug Output

```bash
# Debug specific test
./test/docker/run-container-tests.sh --debug test/debug/debug_test.bats

# Debug multiple tests
./test/docker/run-container-tests.sh --debug "test/debug/*.bats"
```

## Test Environment

### Directory Structure

```
test/docker/
├── README.md              # This documentation
├── run-container-tests.sh # Test runner script
└── ubuntu.Dockerfile      # Test container definition
```

### Container Features

1. Mounted Volumes
   - Project root → /app
   - Tests run from /app directory
   - Real-time code updates

2. Environment Variables
   - DEBUG - Enable debug output
   - BATS_LIB - BATS helper location
   - PATH - Include project binaries

3. MITRE CA Integration
   - Certificates mounted from test/fixtures
   - System CA store updated
   - Enables secure downloads

## Best Practices

1. Pattern Usage
   - Quote patterns with wildcards
   - Use specific patterns during development
   - Use recursive patterns for full test runs

2. Debug Mode
   - Use --debug flag for verbose output
   - Debug shows available and found test files
   - Shows pattern matching results

3. Test Organization
   - Group related tests in directories
   - Use consistent naming patterns
   - Follow BATS best practices
