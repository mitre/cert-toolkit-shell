#!/usr/bin/env bash

# Enable strict mode
set -euo pipefail

# Initialize mock tracking arrays
declare -g -A MOCK_CALLS=()
declare -g -A MOCK_OUTPUTS=()
declare -g -A MOCK_STATUSES=()
declare -g -A MOCK_PATTERNS=()
declare -g -A MOCK_CALL_COUNTS=()
declare -g -i TOTAL_MOCK_CALLS=0
declare -g -a MOCKED_FUNCTIONS=()

# Create a mock command
mock_command() {
    local name=$1
    local output=${2:-""}
    local status=${3:-0}
    local pattern=${4:-".*"}

    # Track this mock for cleanup
    MOCKED_FUNCTIONS+=("$name")

    # Initialize arrays for this mock if needed
    MOCK_CALLS["${name}_count"]=0
    MOCK_OUTPUTS["$name"]=$output
    MOCK_STATUSES["$name"]=$status
    MOCK_PATTERNS["$name"]=$pattern
    MOCK_CALL_COUNTS["$name"]=0

    # Create the mock function with proper variable handling
    eval "
        $name() {
            local args=\$*
            local count=\${MOCK_CALL_COUNTS[$name]}
            MOCK_CALLS[${name}_\$count]=\"\$args\"
            MOCK_CALL_COUNTS[$name]=\$((count + 1))
            TOTAL_MOCK_CALLS=\$((TOTAL_MOCK_CALLS + 1))

            if [[ \"\$args\" =~ ${MOCK_PATTERNS[$name]} ]]; then
                [ -n \"${MOCK_OUTPUTS[$name]}\" ] && echo \"${MOCK_OUTPUTS[$name]}\"
                return ${MOCK_STATUSES[$name]}
            fi
            return 1
        }
    "
    export -f "$name"
}

# Assert mock was called
assert_mock_called() {
    local name=$1
    local expected_calls=${2:-1}

    if [[ ${MOCK_CALL_COUNTS[$name]:-0} -ne $expected_calls ]]; then
        echo "Expected $name to be called $expected_calls times"
        echo "Actually called: ${MOCK_CALL_COUNTS[$name]:-0} times"
        return 1
    fi
}

# Assert mock was called with specific arguments
assert_mock_called_with() {
    local name=$1
    shift
    local expected_args="$*"
    local found=0

    for ((i = 0; i < ${MOCK_CALL_COUNTS[$name]:-0}; i++)); do
        if [[ "${MOCK_CALLS[${name}_$i]:-}" == "$expected_args" ]]; then
            found=1
            break
        fi
    done

    if [[ $found -eq 0 ]]; then
        echo "Expected: $name $expected_args"
        echo "Actual calls:"
        for ((i = 0; i < ${MOCK_CALL_COUNTS[$name]:-0}; i++)); do
            echo "  $name ${MOCK_CALLS[${name}_$i]:-}"
        done
        return 1
    fi
}

# New: Assert mock was called with pattern
assert_mock_called_with_pattern() {
    local name=$1
    local pattern=$2
    local found=0

    for ((i = 0; i < ${MOCK_CALL_COUNTS[$name]:-0}; i++)); do
        if [[ "${MOCK_CALLS[${name}_$i]:-}" =~ $pattern ]]; then
            found=1
            break
        fi
    done

    if [[ $found -eq 0 ]]; then
        echo "Expected: $name calls matching '$pattern'"
        echo "Actual calls:"
        get_mock_calls "$name"
        return 1
    fi
}

# New: Assert mock was called in sequence
assert_mock_sequence() {
    local name=$1
    shift
    local -a expected_sequence=("$@")

    if [[ ${#expected_sequence[@]} -ne ${MOCK_CALL_COUNTS[$name]:-0} ]]; then
        echo "Expected ${#expected_sequence[@]} calls, got ${MOCK_CALL_COUNTS[$name]:-0}"
        echo "Actual sequence:"
        get_mock_calls "$name"
        return 1
    fi

    for ((i = 0; i < ${#expected_sequence[@]}; i++)); do
        if [[ "${MOCK_CALLS[${name}_$i]:-}" != "${expected_sequence[$i]}" ]]; then
            echo "Call $i mismatch:"
            echo "Expected: ${expected_sequence[$i]}"
            echo "Got: ${MOCK_CALLS[${name}_$i]:-}"
            return 1
        fi
    done
}

# Get all calls for a mock
get_mock_calls() {
    local name=$1
    local calls=()

    for ((i = 0; i < ${MOCK_CALL_COUNTS[$name]:-0}; i++)); do
        echo "${MOCK_CALLS[${name}_$i]:-}"
    done
}

# Reset all mocks
reset_mocks() {
    # Clear all mock tracking
    MOCK_CALLS=()
    MOCK_OUTPUTS=()
    MOCK_STATUSES=()
    MOCK_PATTERNS=()
    MOCK_CALL_COUNTS=()
    TOTAL_MOCK_CALLS=0

    # Unset any functions we created
    for fn in "${MOCKED_FUNCTIONS[@]}"; do
        unset -f "$fn" || true
    done
    MOCKED_FUNCTIONS=()
}

# New: Enhanced debug output
debug_mock_state() {
    local name=$1
    local verbose=${2:-false}

    echo "=== Mock '$name' State ==="
    echo "Total calls: ${MOCK_CALL_COUNTS[$name]:-0}"
    echo "Pattern: ${MOCK_PATTERNS[$name]:-any}"
    echo "Default output: ${MOCK_OUTPUTS[$name]:-none}"
    echo "Default status: ${MOCK_STATUSES[$name]:-0}"

    if [[ ${MOCK_CALL_COUNTS[$name]:-0} -gt 0 ]]; then
        echo "Call history:"
        get_mock_calls "$name" | while read -r call; do
            echo "  → $call"
        done

        if $verbose; then
            echo "Detailed call analysis:"
            for ((i = 0; i < ${MOCK_CALL_COUNTS[$name]:-0}; i++)); do
                echo "Call $i:"
                echo "  Args: ${MOCK_CALLS[${name}_$i]:-}"
                echo "  Matched pattern: ${MOCK_PATTERNS[$name]:-any}"
            done
        fi
    fi
    echo "======================="
}

# New: Mock with multiple patterns and responses
mock_command_with_responses() {
    local name=$1
    shift
    local -A patterns=()
    local -A outputs=()
    local -A statuses=()

    # Parse pattern/output/status tuples
    while [[ $# -gt 0 ]]; do
        local pattern=$1
        local output=$2
        local status=$3
        patterns[$pattern]=$pattern
        outputs[$pattern]=$output
        statuses[$pattern]=$status
        shift 3
    done

    # Create advanced mock function
    eval "
        $name() {
            local args=\"\$*\"
            MOCK_CALLS[${name}_\${MOCK_CALL_COUNTS[$name]}]=\$args
            ((MOCK_CALL_COUNTS[$name]++))
            ((TOTAL_MOCK_CALLS++))
            
            # Try each pattern
            for pattern in \"\${!patterns[@]}\"; do
                if [[ \$args =~ \$pattern ]]; then
                    [[ -n \"\${outputs[\$pattern]}\" ]] && echo \"\${outputs[\$pattern]}\"
                    return \${statuses[\$pattern]}
                fi
            done
            return 1
        }
    "
    export -f "$name"
}
