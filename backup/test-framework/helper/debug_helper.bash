#!/usr/bin/env bash

# Simple debug output function
debug() {
    if [ "${DEBUG:-}" = "true" ]; then
        printf "# %-20s: %s\n" "${1:-}" "${2:-}" >&3
    fi
}

# Print environment information
debug_environment() {
    debug "BATS_ROOT" "${BATS_ROOT:-unset}"
    debug "BATS_TEST_DIRNAME" "${BATS_TEST_DIRNAME:-unset}"
    debug "PROJECT_ROOT" "${PROJECT_ROOT:-unset}"
    debug "TEST_ROOT" "${TEST_ROOT:-unset}"
    debug "TEST_TEMP" "${TEST_TEMP:-unset}"
}

# Print mock state
debug_mock_state() {
    debug "TOTAL_MOCK_CALLS" "${TOTAL_MOCK_CALLS:-0}"
    debug "MOCK_FUNCTIONS" "${MOCKED_FUNCTIONS[*]:-none}"
}

# Simple mock call debug
debug_mock_call() {
    if [ "${DEBUG:-}" = "true" ]; then
        local cmd="$1"
        local args="$2"
        printf "# Mock call: %s %s\n" "$cmd" "$args" >&3
    fi
}

# Enhanced debug output for test execution
debug_test_step() {
    if [ "${DEBUG:-}" = "true" ]; then
        echo "=== Test Step: $1 ===" >&3
        echo "Test: $BATS_TEST_NAME" >&3
        echo "Working Directory: $(pwd)" >&3
        echo "Test Temp: $TEST_TEMP" >&3
        echo "Command: $2" >&3
        echo "Arguments: $3" >&3
        echo "===================" >&3
    fi
}

# Enhanced certificate operation debug with mock state
debug_cert_operation() {
    if [ "${DEBUG:-}" = "true" ]; then
        echo "=== Certificate Operation ===" >&3
        echo "Operation: $1" >&3
        echo "File: $2" >&3
        echo "Exit Code: $3" >&3
        echo "Output: $4" >&3
        echo "Mock State:" >&3
        debug_mock_detail "openssl"
        echo "Mock Calls:" >&3
        get_mock_calls "openssl" | while read -r call; do
            echo "  → $call" >&3
        done
        echo "=========================" >&3
    fi
}

# Debug mock state during test
debug_test_state() {
    if [ "${DEBUG:-}" = "true" ]; then
        echo "=== Current Test State ===" >&3
        echo "TOTAL_CERTS: ${TOTAL_CERTS:-0}" >&3
        echo "PEM_CERTS: ${PEM_CERTS:-0}" >&3
        echo "DER_CERTS: ${DER_CERTS:-0}" >&3
        echo "FAILED_CERTS: ${FAILED_CERTS:-0}" >&3
        echo "SKIPPED_CERTS: ${SKIPPED_CERTS:-0}" >&3
        echo "======================" >&3
    fi
}

# Add detailed mock debugging
debug_mock_detail() {
    if [ "${DEBUG:-}" = "true" ]; then
        local mock_name=$1
        echo "=== Mock Detail: $mock_name ===" >&3
        echo "Call count: ${MOCK_CALL_COUNTS[$mock_name]:-0}" >&3
        echo "Pattern: ${MOCK_PATTERNS[$mock_name]:-none}" >&3
        echo "Output: ${MOCK_OUTPUTS[$mock_name]:-none}" >&3
        echo "Status: ${MOCK_STATUSES[$mock_name]:-0}" >&3
        echo "Last args: ${MOCK_CALLS[${mock_name}_0]:-none}" >&3
        echo "=========================" >&3
    fi
}

# Debug file operations
debug_file_operation() {
    if [ "${DEBUG:-}" = "true" ]; then
        local file="$1"
        local op="$2"
        echo "=== File Operation: $op ===" >&3
        echo "File: $file" >&3
        echo "Exists: $([ -f "$file" ] && echo "yes" || echo "no")" >&3
        if [ -f "$file" ]; then
            echo "Size: $(wc -c <"$file")" >&3
            echo "Permissions: $(ls -l "$file")" >&3
            echo "Content (first line):" >&3
            head -n1 "$file" >&3
        fi
        echo "Directory content:" >&3
        ls -la "$(dirname "$file")" >&3
        echo "=========================" >&3
    fi
}

# Debug OpenSSL operations
debug_openssl_operation() {
    if [ "${DEBUG:-}" = "true" ]; then
        local cmd="$1"
        local file="$2"
        echo "=== OpenSSL Operation ===" >&3
        echo "Command: $cmd" >&3
        echo "File: $file" >&3
        echo "File type: $(file "$file")" >&3
        echo "File size: $(wc -c <"$file")" >&3
        echo "Mock state:" >&3
        debug_mock_detail "openssl"
        echo "=========================" >&3
    fi
}

# Debug DER certificate operations
debug_der_operation() {
    if [ "${DEBUG:-}" = "true" ]; then
        local file="$1"
        local stage="$2"
        echo "=== DER Certificate Operation: $stage ===" >&3
        echo "File: $file" >&3
        echo "File exists: $([ -f "$file" ] && echo "yes" || echo "no")" >&3
        if [ -f "$file" ]; then
            echo "File type: $(file "$file" 2>/dev/null || echo "unknown")" >&3
            echo "File size: $(wc -c <"$file")" >&3
            echo "First 32 bytes:" >&3
            head -c 32 "$file" | xxd >&3
        fi
        echo "Mock state:" >&3
        debug_mock_detail "openssl"
        echo "=========================" >&3
    fi
}

# Debug DER conversion
debug_der_conversion() {
    if [[ "${DEBUG:-}" != "true" ]]; then
        return 0
    fi

    local input=$1
    local output=$2

    echo "=== DER Conversion Debug ===" >&3
    echo "Input file: $input" >&3
    echo "Output file: $output" >&3
    echo "xxd available: $(command -v xxd >/dev/null 2>&1 && echo "yes" || echo "no")" >&3
    echo "Using method: $(command -v xxd >/dev/null 2>&1 && echo "xxd" || echo "openssl")" >&3
    echo "=========================" >&3
}
