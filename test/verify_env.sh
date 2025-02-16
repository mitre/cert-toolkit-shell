#!/bin/bash

# Colors for output
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

verify_path() {
    local tool=$1
    local expected_path=$2

    if command -v "$tool" | grep -q "$expected_path"; then
        echo -e "${GREEN}✓ $tool is correctly configured${NC}"
        return 0
    else
        echo -e "${RED}✗ $tool is not using the GNU version from Homebrew${NC}"
        echo "Expected: $expected_path"
        echo "Found: $(command -v "$tool")"
        return 1
    fi
}

echo -e "${YELLOW}Verifying environment setup...${NC}"

# Verify GNU tools
verify_path "sed" "/opt/homebrew/opt/gnu-sed/libexec/gnubin"
verify_path "date" "/opt/homebrew/opt/coreutils/libexec/gnubin"
verify_path "openssl" "/opt/homebrew/opt/openssl@3/bin"

# Verify BATS
if bats --version >/dev/null 2>&1; then
    echo -e "${GREEN}✓ BATS is available${NC}"
else
    echo -e "${RED}✗ BATS is not installed${NC}"
fi
