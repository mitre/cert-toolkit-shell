#!/usr/bin/env bash

# Load bats-support and bats-assert
load '../lib/bats-support/load'
load '../lib/bats-assert/load'

# Setup test environment
setup_suite() {
    # Create static test directory
    export TESTS_DIR="$BATS_TEST_DIRNAME"
    export TEST_DATA_DIR="$TESTS_DIR/fixtures"
    export TEST_TEMP_DIR="$BATS_FILE_TMPDIR"
}

# Teardown test environment
teardown_suite() {
    rm -rf "$TEST_TEMP_DIR"
}
