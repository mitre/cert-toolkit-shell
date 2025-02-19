# Command Reference

## Global Options

All commands support:

```bash
--help, -h      # Show help
--version, -v   # Show version
--debug, -d     # Enable debug output
--quiet, -q     # Suppress output
--verbose       # Show detailed output
```

## Commands

### process

Process certificates from various sources

```bash
cert-manager process [options]

Options:
  --ca-skip           Skip CA certificates
  --dod-skip          Skip DoD certificates
  --org-skip          Skip org certificates
  --pem-file=FILE     Use combined PEM file
```

### verify

Verify certificate validity

```bash
cert-manager verify <certificate>

Options:
  --debug     Show verification details
```

### info

Show certificate information

```bash
cert-manager info <certificate> [options]

Options:
  -s         Show subject
  -i         Show issuer
  -d         Show dates
  -a         Show all info
```

### config

Manage configuration

```bash
cert-manager config [options]

Options:
  --list      Show current config
  --verbose   Show detailed config
  --set KEY=VALUE  Set config value
```

## See Also

- [Quick Start](quickstart.md)                # Fixed relative path
- [Debug Guide](../tech/debug.md)            # Updated from DEBUG.md
- [Configuration](../tech/config.md)         # Added missing reference
- [User Guide](README.md)                    # Added missing reference
