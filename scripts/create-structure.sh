#!/bin/bash
set -euo pipefail

# Create directory structure
mkdir -p \
    test/lib \
    test/fixtures/certs \
    test/unit \
    test/integration \
    test/helper

# Create .gitkeep files to track empty directories
touch \
    test/lib/.gitkeep \
    test/fixtures/certs/.gitkeep \
    test/unit/.gitkeep \
    test/integration/.gitkeep
