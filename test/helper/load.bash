#!/usr/bin/env bash

# Enable debug output for loader
[[ "${DEBUG:-}" == "true" ]] && set -x

# Get the test library path from environment or use default
BATS_LIB=${BATS_LIB:-/usr/lib/bats}

# Load core BATS support libraries
load "${BATS_LIB}/bats-support/load.bash"
load "${BATS_LIB}/bats-assert/load.bash"

# Load our helpers (order matters)
HELPER_DIR="$(dirname "${BASH_SOURCE[0]}")"
[[ "${DEBUG:-}" == "true" ]] && echo "Loading helpers from: $HELPER_DIR" >&3

load "${HELPER_DIR}/debug_helper.bash"
load "${HELPER_DIR}/test_helper.bash"
load "${HELPER_DIR}/test_utils.bash"

# Verify debug_helper functions are loaded
[[ "${DEBUG:-}" == "true" ]] && {
    echo "Loaded functions:" >&3
    declare -F | grep 'run_with_debug' >&3
}

set +x
