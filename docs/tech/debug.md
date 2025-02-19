# Debug System Technical Reference

## Overview

The debug system provides consistent state management and debugging capabilities across all modules.

## Implementation

The debug system uses three synchronized mechanisms:

1. Environment Variables

```bash
# Primary debug flags
export DEBUG=true
export CERT_TOOLKIT_DEBUG=true
```

2. Configuration Array

```bash
# Debug configuration
declare -g -A CONFIG
CONFIG[DEBUG]="true"
```

3. Command Line Processing

```bash
# Process debug flag
--debug, -d    Enable debug mode
```

## State Management

### Initialization Order

1. Parse command line flags
2. Set environment variables
3. Update configuration
4. Initialize debug system

### State Synchronization

```bash
# Ensure consistent state
sync_debug_state() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        export CERT_TOOLKIT_DEBUG=true
        CONFIG[DEBUG]="true"
    fi
}
```

## Debug Output

```bash
# Debug function
debug() {
    if [[ "${CONFIG[DEBUG]:-false}" == "true" ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

# Stack trace
print_stack() {
    local frame=0
    while caller $frame; do
        ((frame++))
    done
}
```

## Advanced Features

### Stack Trace Support

```bash
# Print full stack trace
print_stack() {
    local frame=0
    local IFS=$'\n'
    while read -r line; do
        printf "%2d: %s\n" "$frame" "$line"
        ((frame++))
    done < <(caller "$frame" 2>/dev/null)
}
```

### Debug Levels

```bash
declare -r DBG_INFO=1
declare -r DBG_WARN=2
declare -r DBG_ERROR=3

debug_level() {
    local level="$1"; shift
    local msg="$*"
    
    [[ "${CONFIG[DEBUG_LEVEL]:-0}" -ge "$level" ]] || return 0
    printf "[%s] %s\n" "${DEBUG_LEVELS[$level]}" "$msg" >&2
}
```

## Usage Examples

```bash
# Enable debug mode
export DEBUG=true
./cert-manager.sh process

# Debug specific command
./cert-manager.sh --debug verify cert.pem

# Debug with stack traces
DEBUG=true ./cert-manager.sh --debug process
```

## Related Documentation

- [Architecture Guide](../dev/architecture.md)       # Fixed relative path
- [Configuration System](config.md)                  # Added missing reference
- [Testing Guide](../testing/framework.md)          # Updated path to specific doc
- [Coding Standards](../standards/coding.md)        # Added missing reference
