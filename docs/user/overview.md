# Certificate Toolkit (Shell Implementation)

Shell script implementation of the Certificate Management Toolkit. Part of the cert-toolkit suite.

## Repository Structure

```bash
.
├── src/
│   └── cert-manager.sh         # Main script
├── test/
│   ├── fixtures/              # Test data
│   │   └── certs/
│   │       ├── test_cert.pem
│   │       └── test_key.pem
│   ├── helper/               # Test helpers
│   │   └── mock_commands.bash
│   ├── shell_compatibility.bats
│   └── test_cert_manager.bats
├── docs/
│   ├── CONTRIBUTING.md
│   └── certificate-management.md
└── scripts/
    ├── release.sh
    └── setup-dev.sh
```

## Features

- Multi-source certificate management:
  - DoD certificates
  - Organizational certificates
  - System CA certificates
- Format handling:
  - PEM/DER/PKCS7 support
  - Automatic format detection and conversion
- Advanced features:
  - Certificate validation
  - Duplicate detection
  - Chain verification
  - Metrics tracking
- Multi-platform support:
  - Debian-based systems
  - RHEL-based systems
- Shell compatibility:
  - Bash
  - Zsh

## Quick Start

```bash
# Install dependencies
./scripts/setup-dev.sh

# Run tests
bats test/*.bats

# Show help
./src/cert-manager.sh --help

# Process certificates
./src/cert-manager.sh -d    # DoD certificates
./src/cert-manager.sh -o    # Organizational certificates
./src/cert-manager.sh -c    # System CA certificates
```

## Development

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for development guidelines.

## Documentation

Detailed documentation available in [docs/certificate-management.md](docs/certificate-management.md).
