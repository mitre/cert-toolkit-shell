#!/usr/bin/env bats

# Menu Basic Command Testing
# Tests basic command processing, version info, help display
# All tests should be independent and clean up after themselves

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

# Basic command tests
@test "menu: no arguments shows help" {
    run "${PROJECT_ROOT}/src/cert-manager.sh"
    [ "$status" -eq 0 ]
    # Verify all required help sections
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "Commands:" ]]
    [[ "$output" =~ "process" ]] # Default command
    [[ "$output" =~ "verify" ]]  # Main commands
    [[ "$output" =~ "info" ]]
    [[ "$output" =~ "config" ]]
}

@test "menu: --version shows correct information" {
    run "${PROJECT_ROOT}/src/cert-manager.sh" --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "version" ]]
    [[ "$output" =~ "1.0.0" ]] # Current version
}

@test "menu: --help shows full help" {
    run "${PROJECT_ROOT}/src/cert-manager.sh" --help
    [ "$status" -eq 0 ]
    # Verify detailed help sections
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "Commands:" ]]
    [[ "$output" =~ "Global Options:" ]]
    [[ "$output" =~ "Process Options:" ]]
    [[ "$output" =~ "Examples:" ]]
}

@test "menu: help command shows same as --help" {
    run "${PROJECT_ROOT}/src/cert-manager.sh" help
    [ "$status" -eq 0 ]
    # Should match --help output
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "Commands:" ]]
    [[ "$output" =~ "Global Options:" ]]
}

@test "menu: command-specific help works" {
    # Test help for each main command
    local commands=("process" "verify" "info" "config")

    for cmd in "${commands[@]}"; do
        echo "Testing help for command: $cmd" # Debug output
        run "${PROJECT_ROOT}/src/cert-manager.sh" "$cmd" --help
        echo "Status: $status" # Debug output
        echo "Output: $output" # Debug output

        [ "$status" -eq 0 ]
        [[ "$output" =~ "Usage:" ]]
        [[ "$output" =~ "${cmd}" ]]
    done
}

@test "menu: unknown command shows error" {
    run "${PROJECT_ROOT}/src/cert-manager.sh" "nonexistent-command"

    echo "Status: $status" # Debug output
    echo "Output: $output" # Debug output

    [ "$status" -eq 1 ]                                    # Should return error status
    [[ "$output" =~ "nonexistent-command" ]]               # Should mention invalid command
    [[ "$output" =~ "unknown" || "$output" =~ "invalid" ]] # Case insensitive error message
}

@test "menu: help output follows standards" {
    run "${PROJECT_ROOT}/src/cert-manager.sh" --help
    [ "$status" -eq 0 ]

    # Check POSIX/GNU required sections
    [[ "$output" =~ "NAME" ]]
    [[ "$output" =~ "SYNOPSIS" ]]
    [[ "$output" =~ "DESCRIPTION" ]]
    [[ "$output" =~ "OPTIONS" ]]
    [[ "$output" =~ "EXIT STATUS" ]]

    # Check option formatting (GNU style)
    [[ "$output" =~ "--help, -h" ]]
    [[ "$output" =~ "--version, -V" ]]

    # Check command presence (CLIG style)
    [[ "$output" =~ "process" ]]
    [[ "$output" =~ "config" ]]

    # Check examples (CLIG requirement)
    [[ "$output" =~ "EXAMPLES" ]]
}

@test "menu: command help follows standards" {
    for cmd in process config verify info; do
        run "${PROJECT_ROOT}/src/cert-manager.sh" "$cmd" --help
        [ "$status" -eq 0 ]

        # Check required sections
        [[ "$output" =~ "NAME" ]]
        [[ "$output" =~ "SYNOPSIS" ]]
        [[ "$output" =~ "OPTIONS" ]]

        # Check command-specific content
        [[ "$output" =~ "$cmd" ]]
    done
}
