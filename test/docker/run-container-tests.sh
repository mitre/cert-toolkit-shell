#!/usr/bin/env bash

set -euo pipefail

# Initialize debug flag from environment or default to false
DEBUG=${DEBUG:-false}

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] [test pattern]

Options:
    test        Run the test suite (default)
    shell       Start an interactive shell in the container
    help        Show this help message
    -D          Enable debug output

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

# Remove existing container and image
echo "Cleaning up existing container and image..."
docker rm -f cert-toolkit-test 2>/dev/null || true
docker rmi -f cert-toolkit-test 2>/dev/null || true

# Rebuild container
echo "Building fresh container..."
docker build -t cert-toolkit-test -f test/docker/ubuntu.Dockerfile .

# Handle command options
case "${1:-test}" in
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
        bats "${2:-test/*.bats}"
    ;;
help | --help | -h)
    usage
    ;;
*)
    echo "Unknown option: ${1:-}"
    usage
    ;;
esac

$DEBUG && echo "Debug mode enabled, DEBUG=$DEBUG"
echo "Done!"
