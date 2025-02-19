# Quick Start Guide

## Installation

```bash
# Clone repository
git clone https://github.com/mitre/cert-toolkit.git
cd cert-toolkit/cert-toolkit-shell

# Run installation
./install.sh
```

## Basic Usage

```bash
# Show help
cert-manager --help

# Process certificates
cert-manager process --ca-skip

# Verify specific certificate
cert-manager verify cert.pem
```

## Common Tasks

### Process DoD Certificates

```bash
cert-manager process --pem-file=dod-certs.pem
```

### Skip Specific Processing

```bash
cert-manager process --ca-skip --dod-skip
```

### Debug Issues

```bash
DEBUG=true cert-manager process --verbose
```

## Next Steps

- [Command Reference](commands.md)
- [Configuration Guide](../tech/config.md)
- [Troubleshooting](../tech/debug.md)
