# Test Container Guide

## Overview

The test container provides a clean, consistent environment for running tests across different platforms.

## Container Setup

### Building

```bash
# Build container
./test/docker/build.sh

# Rebuild with updates
./test/docker/build.sh --no-cache
```

### Running Tests

```bash
# Run all tests
./test/docker/run-container-tests.sh

# Run specific tests
./test/docker/run-container-tests.sh test/menu/
```

### Debug Mode

```bash
# Run with debug output
DEBUG=true ./test/docker/run-container-tests.sh

# Interactive shell
./test/docker/debug-container.sh
```

## Container Structure

### Base Image

```dockerfile
FROM debian:bullseye-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    bats \
    curl \
    openssl \
    ca-certificates
```

### Test Environment

```bash
# Container paths
WORKDIR=/app
TEST_DIR=/app/test
FIXTURE_DIR=/app/test/fixtures

# Environment variables
export CONTAINER_TEST=true
export TEST_MODE=true
```

### Volume Mounts

```bash
# Source code
-v "${PWD}/src:/app/src"

# Test files
-v "${PWD}/test:/app/test"

# Test certificates
-v "${PWD}/test/fixtures/certs:/app/test/fixtures/certs"
```

## Best Practices

1. Clean State

```bash
# Always start fresh
docker rm -f cert-toolkit-test || true
docker run --rm cert-toolkit-test
```

2. Test Isolation

```bash
# Use temporary directories
TEST_TMP=$(mktemp -d)
trap 'rm -rf "$TEST_TMP"' EXIT
```

3. Platform Differences

```bash
# Check for GNU vs BSD tools
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS specific handling
fi
```
