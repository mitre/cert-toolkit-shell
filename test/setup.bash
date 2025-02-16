#!/usr/bin/env bash

# Export test environment variables
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
export REPO_ROOT

# Load test dependencies
load_dep() {
    local name="$1"
    load "${REPO_ROOT}/test/lib/${name}/load.bash"
}

# Load test dependencies
load_dep "bats-support"
load_dep "bats-assert"
