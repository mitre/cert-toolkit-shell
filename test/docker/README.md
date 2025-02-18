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

Usage:

```bash
# Run all tests
./test/docker/run-container-tests.sh

# Run specific tests with debug output
./test/docker/run-container-tests.sh --debug test/debug/*.bats

# Interactive shell for debugging
./test/docker/run-container-tests.sh shell
```

### 2. ubuntu.Dockerfile

Test container definition that provides:

- Base Ubuntu 22.04 environment
- Required packages (bats, curl, openssl, etc.)
- MITRE CA bundle integration
- BATS test helpers

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

1. Test Execution

   ```bash
   # Development workflow
   ./test/docker/run-container-tests.sh --debug test/**/*.bats

   # Single test file
   ./test/docker/run-container-tests.sh test/debug/debug_test.bats

   # Interactive debugging
   ./test/docker/run-container-tests.sh shell
   ```

2. Debug Mode
   - Use --debug flag for verbose output
   - Debug state propagates to tests
   - Container build info shown

3. Test Organization
   - Group related tests in directories
   - Use descriptive test names
   - Follow BATS best practices
