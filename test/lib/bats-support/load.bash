#!/usr/bin/env bash

# Load bats-support from homebrew on macOS or system path on Linux
if [[ "$(uname -s)" == "Darwin" ]]; then
    load "$(brew --prefix)/lib/bats-support/load.bash"
else
    load "/usr/lib/bats/bats-support/load.bash"
fi

# Load custom matchers and assertions
load_matcher() {
    local name="$1"
    load "${BATS_TEST_DIRNAME}/../../lib/matchers/${name}.bash"
}
