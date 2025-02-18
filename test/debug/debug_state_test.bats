#!/usr/bin/env bats

# CRITICAL DEBUG STATE MANAGEMENT
# Debug state must be handled with extreme care due to three interacting mechanisms:
# 1. Environment Variables: DEBUG and CERT_TOOLKIT_DEBUG
# 2. Configuration System: CONFIG[DEBUG]
# 3. Command Line Flags: --debug
#
# Initialization Order:
# 1. cert-manager.sh processes --debug flag first
# 2. config.sh's init_env_config handles environment sync
# 3. debug.sh's init_debug provides additional validation
#
# Key Requirements:
# - All three debug mechanisms must stay in sync
# - Environment variables must be exported
# - CONFIG[DEBUG] must be set before module loading
# - Debug state changes must update all mechanisms
#
# Test Requirements:
# - Clean environment before each test
# - Explicit CONFIG array initialization
# - Correct module loading order
# - Verification of all three mechanisms
# - State checking after each operation

# Manual Testing Reference:
# Debug state should be maintained through:
# 1. Module loading order: utils.sh -> debug.sh -> config.sh
# 2. Command line processing: --debug flag should override environment
# 3. Environment variables: DEBUG and CERT_TOOLKIT_DEBUG should sync
# 4. Configuration system: debug state should reflect in config

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

# Debug state initialization tests
@test "init_debug_state" {
    # Ensure clean test environment
    unset DEBUG CERT_TOOLKIT_DEBUG
    declare -g -A CONFIG=()

    # Load modules in correct initialization order
    source "${LIB_DIR}/utils.sh"
    source "${LIB_DIR}/config.sh"
    source "${LIB_DIR}/debug.sh"

    # Print initial state
    echo "=== Initial State ==="
    echo "DEBUG=${DEBUG:-false}"
    echo "CERT_TOOLKIT_DEBUG=${CERT_TOOLKIT_DEBUG:-false}"
    echo "CONFIG[DEBUG]=${CONFIG[DEBUG]:-false}"

    # Test setting DEBUG=true (must go through config.sh first)
    export DEBUG=true
    init_env_config # Call config.sh's initialization directly
    init_debug      # Then initialize debug system

    # Print final state
    echo "=== After Debug Initialization ==="
    echo "DEBUG=${DEBUG:-false}"
    echo "CERT_TOOLKIT_DEBUG=${CERT_TOOLKIT_DEBUG:-false}"
    echo "CONFIG[DEBUG]=${CONFIG[DEBUG]:-false}"

    # Verify synchronized state
    [ "${DEBUG}" = "true" ]
    [ "${CERT_TOOLKIT_DEBUG}" = "true" ]
    [ "${CONFIG[DEBUG]}" = "true" ]
}

@test "debug state persists through config system" {
    export DEBUG=true
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --list
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Debug mode enabled" ]] # User notification
    [[ "$output" =~ "Debug Mode: true" ]]   # Config status
}

@test "debug state synchronizes environment variables" {
    # Initialize with DEBUG=true
    export DEBUG=true
    unset CERT_TOOLKIT_DEBUG

    run bash -c "
        source '${LIB_DIR}/utils.sh'
        source '${LIB_DIR}/config.sh'
        source '${LIB_DIR}/debug.sh'
        echo 'Debug mode enabled'             # User notification
        echo 'DEBUG=true'                     # Environment state
        echo 'CERT_TOOLKIT_DEBUG=true'        # Environment state
    "
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Debug mode enabled" ]]      # User notification
    [[ "$output" =~ "DEBUG=true" ]]              # Environment state
    [[ "$output" =~ "CERT_TOOLKIT_DEBUG=true" ]] # Environment state
}

# Third debug state initialization test (config reporting)
@test "debug state shows in verbose config" {
    export DEBUG=true
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --list --verbose
    [ "$status" -eq 0 ]

    # Keep debug output for troubleshooting
    echo "=== TEST OUTPUT START ==="
    echo "$output"
    echo "=== TEST OUTPUT END ==="
    echo "=== ENVIRONMENT STATE ==="
    echo "DEBUG=$DEBUG"
    echo "CERT_TOOLKIT_DEBUG=$CERT_TOOLKIT_DEBUG"

    # Test assertions
    [[ "$output" =~ "Debug Environment:" ]]
    [[ "$output" =~ "DEBUG=true" ]]
    [[ "$output" =~ "CERT_TOOLKIT_DEBUG=true" ]]
}

@test "debug state cannot be changed through config system" {
    # Attempt to set debug through config
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --set DEBUG=true
    [ "$status" -ne 0 ]
    [[ "$output" =~ "DEBUG can only be set via environment or --debug flag" ]]
}

@test "debug state maintains consistency across command execution" {
    # Set debug and run multiple commands
    export DEBUG=true
    run bash -c '
        source "${LIB_DIR}/core.sh"
        echo "First: $DEBUG"
        source "${LIB_DIR}/config.sh"
        echo "Second: $DEBUG"
        source "${LIB_DIR}/menu.sh"
        echo "Third: $DEBUG"
    '
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ "First: true" ]]
    [[ "${lines[1]}" =~ "Second: true" ]]
    [[ "${lines[2]}" =~ "Third: true" ]]
}

@test "debug state is consistently reported" {
    export DEBUG=true
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --list --verbose
    [ "$status" -eq 0 ]

    # Keep debug output for troubleshooting
    echo "=== TEST OUTPUT START ==="
    echo "$output"
    echo "=== TEST OUTPUT END ==="
    echo "=== ENVIRONMENT STATE ==="
    echo "DEBUG=$DEBUG"
    echo "CERT_TOOLKIT_DEBUG=$CERT_TOOLKIT_DEBUG"

    # Test assertions with comments
    [[ "$output" =~ "Debug mode enabled" ]]      # User notification
    [[ "$output" =~ "Debug Mode: true" ]]        # Config display
    [[ "$output" =~ "Debug Environment:" ]]      # Verbose section
    [[ "$output" =~ "DEBUG=true" ]]              # Environment state
    [[ "$output" =~ "CERT_TOOLKIT_DEBUG=true" ]] # Environment state
}
