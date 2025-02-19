# User Guide

## Installation

### Prerequisites

- Linux (Debian or RedHat-based system)
- OpenSSL
- curl, wget, unzip
- libxml2-utils (Debian) or libxml2 (RedHat)

### Quick Install

```bash
git clone https://github.com/mitre/cert-toolkit.git
cd cert-toolkit/cert-toolkit-shell
./install.sh
```

## Basic Usage

```bash
# Show help
cert-manager --help

# Process certificates with defaults
cert-manager process

# Show configuration
cert-manager config --list
```

## Configuration

- Default certificate directories
- Processing options
- Certificate sources
- Debug settings

## Commands

1. process - Process certificates
2. verify - Verify certificate
3. info - Show certificate information
4. config - Show/update configuration

## Troubleshooting

Common issues and solutions...

## Related Documentation

- [Command Reference](commands.md)              # Fixed relative path
- [Quick Start Guide](quickstart.md)           # Fixed relative path
- [Development Setup](../dev/setup.md)         # Updated from development-setup.md
- [Configuration Guide](../tech/config.md)     # Added missing reference
