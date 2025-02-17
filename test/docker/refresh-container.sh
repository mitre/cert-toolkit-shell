#!/usr/bin/env bash

set -euo pipefail

# Remove existing container and image
echo "Cleaning up existing container and image..."
docker rm -f cert-toolkit-test 2>/dev/null || true
docker rmi -f cert-toolkit-test 2>/dev/null || true

# Rebuild container
echo "Building fresh container..."
docker build -t cert-toolkit-test -f test/docker/ubuntu.Dockerfile .

# Run tests if requested
if [ "${1:-}" = "test" ]; then
    echo "Running tests..."
    docker run --rm -it \
        -v "$(pwd):/app" \
        -w /app \
        -e DEBUG=true \
        cert-toolkit-test \
        bats "${2:-test/*.bats}"
fi

echo "Container refresh complete!"
