#!/usr/bin/env bash

# Load BATS test dependencies
if [ -d "/usr/lib/bats/bats-support" ]; then
    load "/usr/lib/bats/bats-support/load"
    load "/usr/lib/bats/bats-assert/load"
else
    echo "ERROR: bats-support not found in /usr/lib/bats/bats-support" >&2
    exit 1
fi

# Set up project paths
export PROJECT_ROOT="$BATS_TEST_DIRNAME/.."
export TEST_ROOT="$BATS_TEST_DIRNAME"
export TEST_TEMP="$(mktemp -d)"

# Basic setup
setup() {
    if [[ "${DEBUG:-}" == "true" ]]; then
        echo "Loading cert-manager.sh from ${PROJECT_ROOT}/src/cert-manager.sh" >&3
        echo "PROJECT_ROOT=${PROJECT_ROOT}" >&3
        echo "Working dir: $(pwd)" >&3
        ls -la "${PROJECT_ROOT}/src" >&3
    fi

    # Source the script with error checking
    if [ ! -f "${PROJECT_ROOT}/src/cert-manager.sh" ]; then
        echo "ERROR: cert-manager.sh not found at ${PROJECT_ROOT}/src/cert-manager.sh" >&2
        return 1
    fi

    # Create temporary environment for sourcing
    (
        # Unset all relevant variables that might affect sourcing
        unset BASH_ENV
        unset CDPATH
        unset ENV
        unset BATS_TEST_ARGV
        unset BATS_TEST_NAME

        # Set critical environment variables
        export SCRIPT_NAME="cert-manager.sh"
        export BASH_SOURCE[0]="${PROJECT_ROOT}/src/cert-manager.sh"
        export SOURCING_FOR_TEST=true

        # Source the script
        # shellcheck disable=SC1090
        source "${PROJECT_ROOT}/src/cert-manager.sh"
    )
    local rc=$?

    if [[ "${DEBUG:-}" == "true" ]]; then
        echo "cert-manager.sh sourced with exit code: $rc" >&3
    fi

    return $rc
}

# Basic teardown
teardown() {
    if [[ -d "${TEST_TEMP}" && -n "${TEST_TEMP}" ]]; then
        rm -rf "${TEST_TEMP}"
    fi
}

# Debug helper
debug() {
    if [[ "${DEBUG:-}" == "true" ]]; then
        echo "# $*" >&3
    fi
}
