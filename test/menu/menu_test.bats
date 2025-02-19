#!/usr/bin/env bats

# Menu Integration Testing
# Tests complex menu interactions and flag combinations
# Focused on integration points between commands

load '../test_helper'

setup() {
    # Load required modules in correct order
    source "${LIB_DIR}/utils.sh"
    source "${LIB_DIR}/config.sh"
    source "${LIB_DIR}/menu.sh"
}

teardown() {
    unset DEBUG CERT_TOOLKIT_DEBUG
}

# Flag combination tests
@test "menu handles --debug with other flags" {
    run "${PROJECT_ROOT}/src/cert-manager.sh" --debug config --list
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Debug mode enabled" ]]
    [[ "$output" =~ "Current Configuration:" ]]
}

@test "menu handles --verbose with commands" {
    # First verify the command works without verbose
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --list
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Current Configuration:" ]]
    [[ ! "$output" =~ "URLs:" ]] # Should not show verbose section

    # Now test with verbose flag
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --list --verbose
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Current Configuration:" ]]
    [[ "$output" =~ "URLs:" ]] # Should show verbose section
}

@test "menu preserves flag order independence" {
    # Order shouldn't matter
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --list --verbose
    local output1="$output"
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --verbose --list
    local output2="$output"

    [ "$output1" = "$output2" ]
}

# Note: Basic command tests moved to basic_command_test.bats
# Note: Config command tests moved to config_command_test.bats
