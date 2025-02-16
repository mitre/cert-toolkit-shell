# Certificate Toolkit (Shell Implementation)

A comprehensive certificate management solution for enterprise environments.

## Repository Structure

```bash
cert-toolkit-shell/
├── src/              # Source code
├── test/             # Test files and fixtures
├── docs/             # Documentation
├── scripts/          # Utility scripts
└── backup/           # Original script backup
```

## Features

- Multi-source certificate management
- Format handling (PEM/DER/PKCS7)
- Certificate validation
- Shell compatibility (bash/zsh)
- Comprehensive testing

## Quick Start

```bash
# Install
./scripts/setup-dev.sh

# Run tests
bats test/*.bats

# Use script
./src/cert-manager.sh
```

For detailed documentation, see [docs/certificate-management.md](docs/certificate-management.md)
