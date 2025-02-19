# Development Environment Setup

## Prerequisites

- Bash 4.x or later
- OpenSSL 3.x
- Git
- Docker (optional, for container testing)
- shellcheck (for code validation)
- bats-core and libraries (for testing)

## Quick Start

```bash
# Clone repository
git clone https://github.com/mitre/cert-toolkit.git
cd cert-toolkit/cert-toolkit-shell

# Run setup script
./scripts/setup-dev.sh
```

## Detailed Setup

### 1. Install Dependencies

```bash
# Debian/Ubuntu
sudo apt-get update
sudo apt-get install -y \
    openssl \
    curl \
    git \
    shellcheck \
    bats

# macOS (using Homebrew)
brew install \
    openssl@3 \
    bash \
    shellcheck \
    bats-core \
    bats-support \
    bats-assert
```

### 2. Configure Environment

```bash
# Add to your ~/.bashrc or ~/.zshrc
export CERT_TOOLKIT_ROOT="/path/to/cert-toolkit"
export PATH="$CERT_TOOLKIT_ROOT/bin:$PATH"
```

### 3. Verify Installation

```bash
# Run verification tests
bats test/00-verify-setup.bats

# Check tool versions
openssl version
bash --version
shellcheck --version
```

## Testing Environment

### Local Testing

```bash
# Run all tests
bats test/

# Run specific tests
bats test/menu/
bats test/unit/

# Run with debug output
DEBUG=true bats test/menu/menu_test.bats
```

### Container Testing

```bash
# Build test container
./test/docker/build.sh

# Run tests in container
./test/docker/run-container-tests.sh

# Interactive container shell
./test/docker/debug-container.sh
```

## Development Tools

- shellcheck: Static analysis for shell scripts
- bats-core: Bash testing framework
- bats-support: Support library for Bats
- bats-assert: Assertion library for Bats
- git-hooks: Pre-commit validation

## IDE Setup

### VSCode

```json
{
    "shellcheck.enable": true,
    "shellcheck.useWorkspaceRootAsCwd": true,
    "shellcheck.run": "onSave"
}
```

### Vim/NeoVim

```vim
" Add shellcheck integration
Plugin 'dense-analysis/ale'
let g:ale_linters = {'sh': ['shellcheck']}
```

## See Also

- [Contributing Guide](contributing.md)  # Updated - includes code review process
- [Testing Guide](../testing/README.md)
- [Coding Standards](../standards/coding.md)
