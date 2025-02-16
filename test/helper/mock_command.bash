#!/usr/bin/env bash

# Create a mock command
mock_command() {
    local cmd=$1
    local tmpdir="${TEST_DIR}/mock_bin"
    mkdir -p "$tmpdir"
    cat >"$tmpdir/$cmd" <<'EOF'
#!/bin/bash
echo "Mock $0 called with args: $@" >&2
exit ${MOCK_STATUS:-0}
EOF
    chmod +x "$tmpdir/$cmd"
    export PATH="$tmpdir:$PATH"
}

# Remove a mock command
unmock_command() {
    local cmd=$1
    local tmpdir="${TEST_DIR}/mock_bin"
    rm -f "$tmpdir/$cmd"
}

# Rename to ensure consistent naming
mv mock_command.bash mock_commands.bash
