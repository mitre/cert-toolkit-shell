# Debug State Management

## Overview

Debug state management is a critical system requiring careful coordination between multiple components. This document outlines the requirements, patterns, and pitfalls discovered during implementation.

## Key Components

### 1. Debug Mechanisms

Three mechanisms must stay synchronized:

- Environment Variables: `DEBUG` and `CERT_TOOLKIT_DEBUG`
- Configuration System: `CONFIG[DEBUG]`
- Command Line Flag: `--debug`

### 2. Initialization Order

Critical sequence that must be maintained:

1. Command Line Processing (cert-manager.sh)
   - Process `--debug` flag before any module loading
   - Set environment variables immediately
   - Show initial debug output

2. Configuration Initialization (config.sh)
   - Initialize CONFIG array with debug state
   - Synchronize environment variables
   - Handle debug state inheritance

3. Debug System Setup (debug.sh)
   - Provide additional validation
   - Maintain state consistency
   - Initialize logging system

## Implementation Requirements

### 1. Early Debug Flag Processing

```bash
# Must occur before any module loading
while [[ $# -gt 0 ]]; do
    case "$1" in
    --debug|-d)
        export DEBUG=true
        export CERT_TOOLKIT_DEBUG=true
        shift
        ;;
    esac
done
```

### 2. Environment Variable Handling

- Always export both variables together
- Use consistent naming
- Check both variables for state

### 3. Configuration Integration

- Initialize CONFIG[DEBUG] early
- Maintain synchronization
- Handle state changes properly

## Testing Requirements

### 1. Environment Cleanup

```bash
setup() {
    unset DEBUG CERT_TOOLKIT_DEBUG
    declare -g -A CONFIG=()
}
```

### 2. State Verification

Check all three mechanisms:

- Environment variables
- Configuration system
- Command line processing

### 3. Module Loading Order

Test modules must be loaded in correct order:

1. utils.sh
2. config.sh
3. debug.sh

## Common Pitfalls

1. **Module Loading Order**
   - Loading debug.sh before config.sh
   - Missing utils.sh dependencies
   - Incomplete initialization

2. **Environment Variables**
   - Not exporting variables
   - Checking only one variable
   - Missing synchronization

3. **State Management**
   - Inconsistent state between mechanisms
   - Missing initialization steps
   - Incomplete cleanup

## Best Practices

1. **Debug State Changes**

   ```bash
   # Always set all three mechanisms
   export DEBUG=true
   export CERT_TOOLKIT_DEBUG=true
   CONFIG[DEBUG]="true"
   ```

2. **State Verification**

   ```bash
   # Check all mechanisms
   [ "${DEBUG:-false}" = "true" ]
   [ "${CERT_TOOLKIT_DEBUG:-false}" = "true" ]
   [ "${CONFIG[DEBUG]:-false}" = "true" ]
   ```

3. **Testing**
   - Clean environment before each test
   - Verify all mechanisms
   - Test all initialization paths

## Related Files

- src/cert-manager.sh (Initial debug processing)
- src/lib/config.sh (State management)
- src/lib/debug.sh (Debug system)
- test/debug/debug_state_test.bats (Test cases)
