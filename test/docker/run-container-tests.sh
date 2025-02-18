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
        # Anything else is treated as test pattern
        TEST_PATTERN="$1"
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
    echo -e "\nAvailable test files:"
    find test/debug -name "*.bats" -type f | sort | sed 's/^/  - /'
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
    docker run --rm -it \
        -v "$(pwd):/app" \
        -w /app \
        -e "DEBUG=$DEBUG" \
        cert-toolkit-test \
        bash -c '
            cd /app
            # Find test files using pattern
            mapfile -t test_files < <(find test/debug -name "*.bats" -type f | sort)

            # Show what we found
            echo "Found test files:"
            for file in "${test_files[@]}"; do
                echo "  - $file"
            done

            # Run tests if we found any
            if [[ ${#test_files[@]} -gt 0 ]]; then
                echo -e "\nRunning ${#test_files[@]} test files...\n"
                bats "${test_files[@]}"
            else
                echo "No test files found"
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
