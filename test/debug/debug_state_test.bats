#!/usr/bin/env bats

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

@test "debug state initializes correctly through module loading" {
    # Start with no debug
    unset DEBUG CERT_TOOLKIT_DEBUG
    source "${LIB_DIR}/core.sh"
    [ "${DEBUG:-false}" = "false" ]
    [ "${CERT_TOOLKIT_DEBUG:-false}" = "false" ]

    # Initialize with DEBUG=true
    export DEBUG=true
    source "${LIB_DIR}/core.sh"
    [ "${DEBUG:-}" = "true" ]
    [ "${CERT_TOOLKIT_DEBUG:-}" = "true" ]

    # Initialize with CERT_TOOLKIT_DEBUG=true
    unset DEBUG
    export CERT_TOOLKIT_DEBUG=true
    source "${LIB_DIR}/core.sh"
    [ "${DEBUG:-}" = "true" ]
    [ "${CERT_TOOLKIT_DEBUG:-}" = "true" ]
}

@test "debug state persists through config system" {
    # Set debug through environment
    export DEBUG=true
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --list
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Debug mode enabled" ]]
    [[ "$output" =~ "Debug Mode: true" ]]

    # Set debug through command line
    unset DEBUG CERT_TOOLKIT_DEBUG
    run "${PROJECT_ROOT}/src/cert-manager.sh" --debug config --list
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Debug mode enabled" ]]
    [[ "$output" =~ "Debug Mode: true" ]]
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
