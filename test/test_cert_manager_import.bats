#!/usr/bin/env bats

load 'helper/test_helper'
load 'helper/mock_command'

setup() {
    setup_test_env
    load_test_certs
    setup_mock_commands
}

teardown() {
    cleanup_test_env
}

@test "import-dod command works" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" import-dod
    [ "$status" -eq 0 ]
}

@test "import-org command works" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" import-org
    [ "$status" -eq 0 ]
}

@test "import-system command works" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" import-system
    [ "$status" -eq 0 ]
}

@test "import-all command works" {
    run "${BATS_TEST_DIRNAME}/../src/cert-manager.sh" import-all
    [ "$status" -eq 0 ]
}
