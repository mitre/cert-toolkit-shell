# Installation Guide

## Prerequisites

- Linux/Unix-based system
- Bash 4.x or later
- OpenSSL 3.x
- curl or wget
- git (for development)

## Standard Installation

```bash
# Clone repository
git clone https://github.com/mitre/cert-toolkit.git
cd cert-toolkit/cert-toolkit-shell

# Run installer
./install.sh
```

## System Requirements

- 512MB RAM minimum
- 1GB disk space
- Internet connection for updates

## Verification

```bash
# Check installation
cert-manager --version

# Verify functionality
cert-manager verify --help
```

## Troubleshooting

See [Debug Guide](../tech/debug.md) for detailed troubleshooting.

## Related Documentation

- [Quick Start Guide](quickstart.md)
- [Configuration](../tech/config.md)
- [User Guide](README.md)
