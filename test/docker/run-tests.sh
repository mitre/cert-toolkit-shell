#!/usr/bin/env bash

# Build and run tests in Ubuntu container
docker build -t cert-toolkit-test -f test/docker/ubuntu.Dockerfile .

# Run all tests by default
docker run --rm -it \
    -v "$(pwd):/app" \
    -w /app \
    cert-toolkit-test \
    bats test/*.bats

# Run specific test if provided
if [ "$1" ]; then
    docker run --rm -it \
        -v "$(pwd):/app" \
        -w /app \
        cert-toolkit-test \
        bats "test/$1"
fi
