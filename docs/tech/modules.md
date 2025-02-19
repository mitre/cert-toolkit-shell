# Module System

## Overview

The module system provides:

- Dependency management
- State isolation
- Error handling
- Debug support

## Module Structure

```bash
#!/bin/bash
#
# Module: name
# Purpose: brief description
# Dependencies: list of required modules

# 1. Guard pattern
if [[ -n "${MODULE_LOADED:-}" ]]; then
    return 0
fi
declare -r MODULE_LOADED=true

# 2. Module interface
declare -g -r MODULE_VERSION="1.0.0"
declare -g -A MODULE_CONFIG=()

# 3. Public functions
function public_function() {
    # Implementation
}

# 4. Private functions
function _private_helper() {
    # Implementation
}
```

## Loading Order

1. utils.sh: Base utilities
2. debug.sh: Debug system
3. config.sh: Configuration
4. Other modules
5. menu.sh: User interface

## State Management

- Each module manages its own state
- Configuration through CONFIG array
- Debug through debug system
- Clean error handling

## Best Practices

1. Use guard patterns
2. Document dependencies
3. Clear public interface
4. Proper error handling

## See Also

- [Architecture Guide](../dev/architecture.md)       # Fixed relative path
- [Debug System](debug.md)                          # Fixed relative path
- [Configuration System](config.md)                 # Added missing reference
- [Coding Standards](../standards/coding.md)        # Added missing reference
