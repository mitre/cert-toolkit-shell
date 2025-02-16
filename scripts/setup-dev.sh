#!/bin/bash
set -euo pipefail

# Colors for output
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

echo -e "${YELLOW}Setting up development environment...${NC}"

# Install dependencies based on platform
case "$(uname -s)" in
Darwin*)
    echo "macOS detected, setting up with Homebrew..."

    # Add bats-core tap and install BATS with helpers
    brew tap bats-core/bats-core
    brew install \
        bats-core \
        bats-core/bats-core/bats-support \
        bats-core/bats-core/bats-assert \
        bats-core/bats-core/bats-file \
        coreutils \
        openssl@3 \
        gnu-sed \
        wget

    # Configure PATH for GNU tools
    SHELL_RC="$HOME/.$(basename "$SHELL")rc"
    if ! grep -q "cert-toolkit-shell" "$SHELL_RC" 2>/dev/null; then
        cat >>"$SHELL_RC" <<EOF
# cert-toolkit-shell development environment
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:\$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:\$PATH"
export PATH="/opt/homebrew/opt/openssl@3/bin:\$PATH"
EOF
    fi
    ;;

Linux*)
    echo "Linux detected, setting up..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y \
            bats \
            curl \
            openssl \
            wget
    fi
    ;;
esac

# Setup directory structure
echo -e "${YELLOW}Setting up directory structure...${NC}"
./scripts/create-structure.sh

# Setup git hooks
echo -e "${YELLOW}Setting up git hooks...${NC}"
cat >.git/hooks/pre-commit <<'EOF'
#!/bin/bash
bats test/*.bats
EOF
chmod +x .git/hooks/pre-commit

# Fix file permissions
echo -e "${YELLOW}Setting file permissions...${NC}"
./scripts/fix-permissions.sh

echo -e "${GREEN}Development environment setup complete!${NC}"
echo -e "${YELLOW}NOTE: Run 'source $SHELL_RC' to update your PATH${NC}"

# Verify setup
echo -e "${YELLOW}Verifying setup...${NC}"
if bats test/00-verify-setup.bats; then
    echo -e "${GREEN}✓ Verification successful${NC}"
else
    echo -e "${RED}✗ Verification failed${NC}"
    exit 1
fi
