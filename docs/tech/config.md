# Configuration System

## Overview

The configuration system provides centralized state management and configuration across all modules.

## Implementation

```bash
# Global configuration array
declare -g -A CONFIG=()

# Default values
CONFIG[DEBUG]="false"
CONFIG[CERT_DIR]="/etc/certs"
CONFIG[TIMEOUT]="30"
```

## Configuration Sources

Priority order (highest to lowest):

1. Command line arguments
2. Environment variables
3. Configuration file
4. Default values

## Usage Examples

```bash
# Command line override
cert-manager --debug process

# Environment variables
export CERT_TOOLKIT_DEBUG=true
export CERT_TOOLKIT_CERT_DIR="/custom/path"

# Configuration file
cat ~/.cert-toolkit/config
DEBUG=true
CERT_DIR=/custom/path
```

## API Reference

```bash
# Get configuration value
get_config() {
    local key="$1"
    local default="$2"
    echo "${CONFIG[$key]:-$default}"
}

# Set configuration value
set_config() {
    local key="$1"
    local value="$2"
    CONFIG[$key]="$value"
}
```

## Related Documentation

- [Debug System](debug.md)
- [Module System](modules.md)
- [Command Reference](../user/commands.md)
- [Architecture](../dev/architecture.md)
