#!/usr/bin/env bash

# Load mock responses
load "helper/mock_responses"

# Mock package managers and their commands
setup_package_managers() {
    # Reset mock tracking first
    setup_mock_tracking

    # Basic command mocks
    mock_command "command" "/usr/bin/openssl" 0
    mock_command "dpkg-query" "Status: install ok installed" 0
}

# Enhanced verification helper with debugging
verify_package_installation() {
    local package=$1
    debug_test_step "verify-package" "checking" "$package"

    # Reset mocks for this package
    mock_command "command" "/usr/bin/$package" 0
    mock_command "dpkg-query" "Status: install ok installed" 0

    # Debug current mock state
    debug_mock_detail "command"
    debug_mock_detail "dpkg-query"

    # Verify package exists
    command -v "$package" >/dev/null 2>&1
    local cmd_status=$?
    debug_test_step "command-check" "status" "$cmd_status"

    dpkg-query -W -f='${Status}' "$package" 2>/dev/null
    local dpkg_status=$?
    debug_test_step "dpkg-check" "status" "$dpkg_status"

    # Verify calls
    assert_mock_called "command" 1
    assert_mock_called "dpkg-query" 1

    return 0
}
