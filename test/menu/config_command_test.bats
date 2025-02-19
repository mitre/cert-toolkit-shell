#!/usr/bin/env bats

# Menu Config Command Testing
# Tests configuration display and manipulation
# Verifies config state management

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

@test "config: basic --list shows configuration" {
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --list
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Current Configuration:" ]]
    [[ "$output" =~ "Certificate Directories:" ]]
    [[ "$output" =~ "Processing Flags:" ]]
}

@test "config: --verbose shows detailed config" {
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --list --verbose
    [ "$status" -eq 0 ]
    # Check for verbose-only sections
    [[ "$output" =~ "Current Configuration:" ]]
    [[ "$output" =~ "URLs:" ]]
    [[ "$output" =~ "Certificate Processing Options:" ]]
    [[ "$output" =~ "Debug Mode:" ]]
}

@test "config: invalid options show error" {
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --invalid-option
    [ "$status" -ne 0 ]
    [[ "$output" =~ "Invalid" ]] || [[ "$output" =~ "Unknown" ]]
}

@test "config: all sections present in verbose output" {
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --list --verbose
    [ "$status" -eq 0 ]

    # Required sections in order
    local sections=(
        "Current Configuration:"
        "Certificate Directories:"
        "Processing Flags:"
        "URLs:"
        "Certificate Processing Options:"
    )

    # Verify all sections present
    for section in "${sections[@]}"; do
        [[ "$output" =~ "$section" ]]
    done
}
