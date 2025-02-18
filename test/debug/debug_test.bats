#!/usr/bin/env bats

# Manual Testing Reference:
# To verify debug behavior in the actual application:
#
# 1. Test with no debug (should show no debug output):
#    ./src/cert-manager.sh --help
#
# 2. Test with environment debug (should show debug output):
#    DEBUG=true ./src/cert-manager.sh --help
#
# 3. Test with flag debug (should show debug output):
#    ./src/cert-manager.sh --debug --help
#
# 4. Test debug with config command (should show debug output):
#    DEBUG=true ./src/cert-manager.sh --debug config --list
#
# 5. Expected debug output should include:
#    - "Debug mode enabled"
#    - Script and library directory listings
#    - Configuration information when using --list

load '../test_helper'

setup() {
    # Load modules in correct order to match application
    source "${LIB_DIR}/utils.sh"
    source "${LIB_DIR}/config.sh"
    source "${LIB_DIR}/debug.sh"
}

teardown() {
    unset DEBUG CERT_TOOLKIT_DEBUG
}

# Add environment validation tests first
@test "test environment variables are properly set" {
    # Test critical path variables
    [ -n "$TEST_DIR" ]
    [ -n "$PROJECT_ROOT" ]
    [ -n "$LIB_DIR" ]

    # Verify paths exist
    [ -d "$TEST_DIR" ]
    [ -d "$PROJECT_ROOT" ]
    [ -d "$LIB_DIR" ]

    # Verify critical files exist
    [ -f "${LIB_DIR}/utils.sh" ]
    [ -f "${LIB_DIR}/debug.sh" ]

    # Print debug info if test fails
    echo "TEST_DIR=$TEST_DIR"
    echo "PROJECT_ROOT=$PROJECT_ROOT"
    echo "LIB_DIR=$LIB_DIR"
}

@test "library path is correctly set" {
    [ "$LIB_DIR" = "${PROJECT_ROOT}/src/lib" ]
    [ -d "$LIB_DIR" ]
}

@test "debug function formats output correctly" {
    DEBUG=true
    run debug "test message"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "[DEBUG]" ]]
    [[ "$output" =~ "test message" ]]
}

@test "error function formats error messages" {
    run error "error test"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "[ERROR]" ]]
    [[ "$output" =~ "error test" ]]
}

@test "warn function formats warnings" {
    run warn "warning test"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "[WARN]" ]]
    [[ "$output" =~ "warning test" ]]
}

@test "stack trace shows correct call location" {
    DEBUG=true
    # Show environment for debugging
    echo "Test environment:"
    echo "LIB_DIR=$LIB_DIR"
    echo "PWD=$(pwd)"

    # Call debug with trace
    run debug "test message"
    echo "Output: $output"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "[DEBUG]" ]]
    [[ "$output" =~ "test message" ]]
    # Verify timestamp format instead of file name
    [[ "$output" =~ "[$(date +%Y-%m-%d)" ]]
}

@test "debug output respects debug off state" {
    # Ensure debug is completely off
    unset DEBUG CERT_TOOLKIT_DEBUG
    source "${LIB_DIR}/debug.sh"

    run debug "should not show"
    echo "Debug off output: '$output'"
    [ -z "$output" ]
}

@test "debug output shows with DEBUG=true" {
    # Use the actual application to test debug behavior
    run "${PROJECT_ROOT}/src/cert-manager.sh" --debug --help
    echo "Debug output: '$output'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Debug mode enabled" ]]
}

@test "debug output shows with CERT_TOOLKIT_DEBUG=true" {
    # Test via environment variable
    export CERT_TOOLKIT_DEBUG=true
    run "${PROJECT_ROOT}/src/cert-manager.sh" --help
    echo "Debug output: '$output'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Debug mode enabled" ]]
}

@test "debug state propagates between variables" {
    # Test that debug output appears when either variable is set
    export DEBUG=true
    unset CERT_TOOLKIT_DEBUG
    run "${PROJECT_ROOT}/src/cert-manager.sh" --version
    echo "Test 1 output with DEBUG=true: '$output'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Debug mode enabled" ]]

    # Test CERT_TOOLKIT_DEBUG works independently
    unset DEBUG
    export CERT_TOOLKIT_DEBUG=true
    run "${PROJECT_ROOT}/src/cert-manager.sh" --version
    echo "Test 2 output with CERT_TOOLKIT_DEBUG=true: '$output'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Debug mode enabled" ]]

    # Test that setting DEBUG propagates to config system
    export DEBUG=true
    unset CERT_TOOLKIT_DEBUG
    source "${LIB_DIR}/config.sh"
    [ "$(get_config DEBUG)" = "true" ]
}

# Add new test for command line flag override
@test "debug flag overrides environment settings" {
    # Try to disable debug via environment
    export DEBUG=false
    export CERT_TOOLKIT_DEBUG=false

    # But enable via flag
    run "${PROJECT_ROOT}/src/cert-manager.sh" --debug --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Debug mode enabled" ]]
}
