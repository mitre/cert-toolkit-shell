#!/usr/bin/env bats

load 'helper/test_helper'

setup() {
    setup_test_env
}

teardown() {
    cleanup_test_env
}

@test "script runs in bash" {
    run bash "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" --help
    [ "$status" -eq 0 ]
}

@test "script runs in zsh" {
    if ! command -v zsh >/dev/null; then
        skip "zsh not installed"
    fi
    run zsh "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" --help
    [ "$status" -eq 0 ]
}

@test "script detects required commands" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" --check-deps
    [ "$status" -eq 0 ]
}

@test "cert-manager shows correct version" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" --version
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "cert-manager version" ]]
}
