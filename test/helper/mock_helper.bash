#!/usr/bin/env bash

# Enable strict mode
set -euo pipefail

# Initialize mock tracking arrays
declare -g -A MOCK_CALLS=()
declare -g -A MOCK_OUTPUTS=()
declare -g -A MOCK_STATUSES=()
declare -g -A MOCK_PATTERNS=()
declare -g -A MOCK_CALL_COUNTS=()
declare -g -i TOTAL_MOCK_CALLS=0

# Function to initialize mock tracking
setup_test_environment() {
    mkdir -p "${TEST_FIXTURES}"
    mkdir -p "${TEST_TEMP}"
    setup_mock_tracking
}

# Initialize mock tracking
setup_mock_tracking() {
    MOCK_CALLS=()
    MOCK_OUTPUTS=()
    MOCK_STATUSES=()
    MOCK_PATTERNS=()
    MOCK_CALL_COUNTS=()
    TOTAL_MOCK_CALLS=0
}

# ...rest of existing mock functions...
