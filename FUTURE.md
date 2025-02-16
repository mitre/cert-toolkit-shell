# CERT Toolkit Shell

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

## Usage

```bash
./src/cert-manager.sh [OPTIONS] COMMAND
```

## Commands

- `list` - List installed certificates
- `info CERT` - Display certificate information
- `add-dod-certs` - Add DOD certificates
- `--help` - Show help information
- `--check-deps` - Check for required dependencies

## Examples

```bash
# List all certificates
./src/cert-manager.sh list

# Show certificate information
./src/cert-manager.sh info mycert.pem

# Add DOD certificates
./src/cert-manager.sh add-dod-certs
```

## Development

Run tests:

```bash
bats test/test_cert_manager_*.bats
bats test/shell_compatibility.bats
```

For detailed documentation, see [docs/certificate-management.md](docs/certificate-management.md)
