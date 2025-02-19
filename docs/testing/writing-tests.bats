#!/usr/bin/env bats

# Example Test File
# Demonstrates test writing patterns and best practices

load '../test_helper'

setup() {
    # Standard environment setup
    source "${LIB_DIR}/utils.sh"
    source "${LIB_DIR}/config.sh"
    source "${LIB_DIR}/debug.sh"
}

teardown() {
    # Clean up after each test
    unset DEBUG CERT_TOOLKIT_DEBUG
}

@test "example: basic success test" {
    run some_command
    assert_success
    assert_output "Expected output"
}

@test "example: error handling test" {
    run invalid_command
    assert_failure
    assert_output --partial "error:"
}

@test "example: state management test" {
    # Set initial state
    export DEBUG=true

    # Run command
    run some_command

    # Verify state maintained
    assert_debug_enabled
}

@test "example: edge case test" {
    # Test with edge case input
    run process_input ""
    assert_failure
    assert_output "Error: Empty input"
}
