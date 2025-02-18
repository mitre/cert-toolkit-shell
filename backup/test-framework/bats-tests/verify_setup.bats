#!/usr/bin/env bats

@test "verify bats-support is loaded" {
    load '../lib/bats-support/load'
    [ "$?" -eq 0 ]
}

@test "verify bats-assert is loaded" {
    load '../lib/bats-assert/load'
    [ "$?" -eq 0 ]
}

@test "verify openssl is available" {
    run openssl version
    [ "$status" -eq 0 ]
}

@test "verify test directories exist" {
    [ -d "${BATS_TEST_DIRNAME}/../fixtures/certs" ]
    [ -d "${BATS_TEST_DIRNAME}/../lib" ]
    [ -d "${BATS_TEST_DIRNAME}/../unit" ]
    [ -d "${BATS_TEST_DIRNAME}/../integration" ]
}
