#!/bin/bash

PLATFORMS=(
    "ubuntu:22.04"
    "redhat/ubi9"
    "debian:11"
)

for platform in "${PLATFORMS[@]}"; do
    echo "Testing on $platform"
    docker build -f "test/docker/${platform%%:*}.Dockerfile" -t "cert-toolkit-test-${platform%%:*}" .
    docker run --rm "cert-toolkit-test-${platform%%:*}"
done
