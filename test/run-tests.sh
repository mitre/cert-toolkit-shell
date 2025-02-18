#!/bin/bash

# Guard against running outside container
if [[ ! -f /.dockerenv ]]; then
    echo "This script must be run inside the test container"
    exit 1
fi

# Install BATS if not present
if ! command -v bats &>/dev/null; then
    apt-get update && apt-get install -y bats bats-assert bats-file
fi

# Run specific test or all tests
if [[ -n "$1" ]]; then
    bats "$@"
else
    # Run debug tests first since they're critical
    echo "Running debug system tests..."
    bats test/debug/*.bats
fi
