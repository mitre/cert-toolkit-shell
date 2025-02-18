#!/usr/bin/env bash

set -euo pipefail

# Initialize debug flag from environment or default to false
DEBUG=${DEBUG:-false}

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] [test pattern]

Options:
    test            Run the test suite (default)
    shell           Start an interactive shell in the container
    help            Show this help message
    --debug, -d     Enable debug output

Arguments:
    test pattern    Optional pattern to match specific test files (e.g., "test/debug/*.bats")
EOF
    exit 1
}

# CRITICAL: Process debug flags first, regardless of position
# This matches cert-manager.sh debug handling
for arg in "$@"; do
    if [[ "$arg" == "--debug" || "$arg" == "-d" ]]; then
        export DEBUG=true
        break
    fi
done

# Parse remaining arguments
TEST_PATTERN=""
COMMAND="test"
ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
    --debug | -d)
        # Already handled above, just skip
        shift
        ;;
    test | shell | help)
        COMMAND="$1"
        shift
        ;;
    -*)
        # Handle other flags
        ARGS+=("$1")
        shift
        ;;
    *)
        # Collect all test patterns
        [[ -n "$TEST_PATTERN" ]] && TEST_PATTERN="$TEST_PATTERN $1" || TEST_PATTERN="$1"
        shift
        ;;
    esac
done

# Ensure MITRE CA bundle exists
if [[ ! -f "test/fixtures/certs/mitre-ca-bundle.pem" ]]; then
    echo "Error: MITRE CA bundle not found at test/fixtures/certs/mitre-ca-bundle.pem"
    echo "Please ensure the certificate bundle is in place before running tests"
    exit 1
fi

# Remove existing container and image
echo "Cleaning up existing container and image..."
docker rm -f cert-toolkit-test 2>/dev/null || true
docker rmi -f cert-toolkit-test 2>/dev/null || true

# Rebuild container
echo "Building fresh container..."
docker build -t cert-toolkit-test -f test/docker/ubuntu.Dockerfile .

# Show debug info before test execution
[[ "${DEBUG:-false}" == "true" ]] && {
    echo -e "\nDebug mode enabled"
    echo -e "\nScript directory: $(pwd)"
    echo "Command: $COMMAND"
    echo "Test pattern: ${TEST_PATTERN:-test/**/*.bats}"

    # Show available test files using docker to handle glob patterns
    echo -e "\nAvailable test files:"
    docker run --rm \
        -v "$(pwd):/app" \
        -w /app \
        cert-toolkit-test \
        bash -c 'shopt -s globstar nullglob; for f in test/**/*.bats; do echo "  - $f"; done | sort'
    echo ""
}

# Handle command options
case "$COMMAND" in
shell)
    echo -e "\nStarting interactive shell..."
    docker run --rm -it \
        -v "$(pwd):/app" \
        -w /app \
        -e "DEBUG=$DEBUG" \
        cert-toolkit-test \
        /bin/bash
    ;;
test)
    echo -e "\nRunning tests...\n"
    # Pass pattern directly to container, let it handle expansion
    docker run --rm -it \
        -v "$(pwd):/app" \
        -w /app \
        -e "DEBUG=$DEBUG" \
        cert-toolkit-test \
        bash -c '
            cd /app
            # Enable all pattern matching features
            shopt -s globstar nullglob extglob

            # If no pattern specified, run all tests
            if [[ -z "'"$TEST_PATTERN"'" ]]; then
                mapfile -t test_files < <(find test -name "*.bats" -type f | sort)
            else
                # Use pattern directly - shell will expand it inside container
                test_files=('"$TEST_PATTERN"')
            fi

            # Show what we found
            echo -e "\nFound test files:\n"
            for file in "${test_files[@]}"; do
                echo "  - $file"
            done

            # Run tests if we found any
            if [[ ${#test_files[@]} -gt 0 ]]; then
                echo -e "\nRunning ${#test_files[@]} test files...\n"
                bats "${test_files[@]}"
            else
                echo "No test files found matching pattern: '"$TEST_PATTERN"'"
                exit 1
            fi
        '
    ;;
help | --help | -h)
    usage
    ;;
*)
    echo "Unknown command: $COMMAND"
    usage
    ;;
esac
