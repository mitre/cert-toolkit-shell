#!/usr/bin/env bats

load '../test_helper'
load '../lib/mock_helper'

setup() {
    setup_test_environment
    reset_mocks
}

teardown() {
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
