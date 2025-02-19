# Shell Script Coding Standards

## Overview

These standards follow:

- Google Shell Style Guide
- GNU Coding Standards
- POSIX Shell Guidelines
- ShellCheck Rules

## Script Requirements

### File Structure

```bash
#!/bin/bash
#
# Module: name
# Description: brief description
# Dependencies: list of required modules
#
# Usage: how to use the script
# Examples: practical examples
#
# Author: name
# Date: YYYY-MM-DD

# 1. Guard pattern (for modules)
# 2. Constants and configurations
# 3. Function definitions
# 4. Main execution (if entry point)
```

### Strict Mode

```bash
set -euo pipefail
shopt -s extdebug nullglob

# For modules that are sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    set +e +u # Less strict for sourced files
fi
```

### Variable Declarations

```bash
# Constants (uppercase, readonly)
declare -r MAX_RETRIES=3
declare -r DEFAULT_TIMEOUT=30

# Global variables (prefixed)
declare -g g_state="initial"
declare -g -A g_config=()

# Local variables (lowercase)
local temp_file
local -a cert_list=()
```

### Function Definitions

```bash
# Standard function
function do_something() {
    local arg1="$1"
    local arg2="${2:-default}"
}

# One-line functions
die() { echo "Error: $*" >&2; exit 1; }
```

## Error Handling

### Standard Error Pattern

```bash
# Return early pattern
if [[ ! -f "$file" ]]; then
    error "File not found: $file"
    return 1
fi

# Command checking
if ! output=$(some_command); then
    error "Command failed: $output"
    return 1
fi
```

### Error Functions

```bash
error() {
    echo "${SCRIPT_NAME}: error: $1" >&2
    return "${2:-1}"
}

warn() {
    echo "${SCRIPT_NAME}: warning: $1" >&2
}
```

## Module System

### Guard Pattern

```bash
# At start of module
if [[ -n "${MODULE_LOADED:-}" ]]; then
    return 0
fi
declare -r MODULE_LOADED=true
```

### Dependencies

```bash
# Required modules first
source "${LIB_DIR}/utils.sh"  # Base utilities
source "${LIB_DIR}/config.sh" # Configuration
source "${LIB_DIR}/debug.sh"  # Debug functions
```

### Module Interface

```bash
# Public interface
declare -g -r MODULE_VERSION="1.0.0"
declare -g -A MODULE_CONFIG=()

# Public functions
function public_function() {
    # Implementation
}

# Private functions (prefixed with _)
function _private_helper() {
    # Implementation
}
```

## Command Line Interface

### Option Processing

```bash
while getopts ":hvdf:" opt; do
    case $opt in
        h) show_help ;;
        v) show_version ;;
        d) enable_debug ;;
        f) process_file "$OPTARG" ;;
        :) die "Option -$OPTARG requires argument" ;;
        \?) die "Invalid option: -$OPTARG" ;;
    esac
done
```

### Long Options

```bash
for arg; do
    case "$arg" in
        --help) show_help ;;
        --version) show_version ;;
        --debug) enable_debug ;;
        --file=*) process_file "${arg#*=}" ;;
        --*) die "Unknown option: $arg" ;;
    esac
done
```

## Style Rules

### Naming Conventions

- Functions: lowercase with underscores
- Variables: lowercase for local, prefixed for global
- Constants: uppercase with underscores
- Private items: prefixed with underscore

### Formatting

- 2-space indentation
- 80-character line limit
- Space after keywords
- Space around operators

### Comments

- Start with space after #
- Full sentences for multi-line
- Explain why, not what

## Testing Requirements

### Test Coverage

- All public functions
- Error conditions
- Edge cases
- State changes

### Test Organization

```bash
# Test file structure
setup() {
    # Initialize test environment
}

teardown() {
    # Clean up after test
}

@test "descriptive name" {
    # Single test case
}
```

## See Also

- [Documentation Standards](documentation.md)
- [Testing Standards](../testing/framework.md)
- [Security Standards](security.md)

## Related Documentation

- [Implementation Guide](../dev/standardization.md)
- [External Standards](references.md)  # Added new reference
- [Documentation Standards](documentation.md)
- [Security Standards](security.md)
