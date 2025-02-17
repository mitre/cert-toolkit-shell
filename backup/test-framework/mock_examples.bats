#!/usr/bin/env bats

# Load bats libraries first
load "$(brew --prefix)/lib/bats-support/load.bash"
load "$(brew --prefix)/lib/bats-assert/load.bash"

# Load from helper directory
load "${BATS_TEST_DIRNAME}/../helper/mock_command"

setup() {
    TEST_TEMP="$(mktemp -d)"
    setup_mock_tracking
}

teardown() {
    rm -rf "${TEST_TEMP}"
    reset_mocks
}

@test "mock_command creates a function" {
    mock_command "test_cmd" "hello" 0
    type test_cmd | grep -q "test_cmd is a function"
}

@test "mock returns configured output" {
    mock_command "echo_test" "hello world" 0
    run echo_test
    assert_success
    assert_output "hello world"
}

@test "mock tracks calls" {
    mock_command "tracked_cmd"
    tracked_cmd one
    tracked_cmd two
    assert_mock_called "tracked_cmd" 2
}

@test "mock matches patterns" {
    mock_command "grep" "found" 0 ".*\.txt"

    run grep pattern file.txt
    assert_success
    assert_output "found"

    run grep pattern file.doc
    assert_failure
}
