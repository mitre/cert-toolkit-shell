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
    -D              Enable debug output
    --watch         Run tests in watch mode
    --watch-debug   Run tests in watch mode with debug output

Arguments:
    test pattern    Optional pattern to match specific test files (e.g., "test/real/*.bats")
EOF
    exit 1
}

# Process -D flag if present in any position
for arg in "$@"; do
    if [[ "$arg" == "-D" ]]; then
        DEBUG=true
        break
    fi
done

# Parse arguments
WATCH_MODE=false
TEST_PATTERN=""
COMMAND="test"

while [[ $# -gt 0 ]]; do
    case "$1" in
    --watch)
        WATCH_MODE=true
        shift
        ;;
    --watch-debug)
        WATCH_MODE=true
        export DEBUG=true
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

# Handle command options
case "$COMMAND" in
shell)
    echo "Starting interactive shell..."
    docker run --rm -it \
        -v "$(pwd):/app" \
        -w /app \
        -e "DEBUG=$DEBUG" \
        cert-toolkit-test \
        /bin/bash
    ;;
test)
    echo "Running tests..."
    docker run --rm -it \
        -v "$(pwd):/app" \
        -w /app \
        -e "DEBUG=$DEBUG" \
        cert-toolkit-test \
        bats ${TEST_PATTERN:-"test/**/*.bats"}
    ;;
help | --help | -h)
    usage
    ;;
*)
    echo "Unknown command: $COMMAND"
    usage
    ;;
esac

$DEBUG && echo "Debug mode enabled, DEBUG=$DEBUG"
echo "Done!"
