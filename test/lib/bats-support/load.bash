# Load bats-support
load_lib() {
    local name="$1"
    load "${BATS_TEST_DIRNAME}/../../lib/${name}/load.bash"
}

# Load custom matchers and assertions
load_matcher() {
    local name="$1"
    load "${BATS_TEST_DIRNAME}/../../lib/matchers/${name}.bash"
}
