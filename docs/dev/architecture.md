# Certificate Toolkit Architecture

## Component Overview

```
cert-manager.sh (Entry Point)
    └─> core.sh (Module Loader)
        └─> menu.sh (UI Layer)
            └─> modules (Implementation Layer)
```

## Layer Responsibilities

### 1. Entry Point (cert-manager.sh)

- Process early debug flags
- Load core.sh
- Call main_menu()
- Handle exit codes

Key feature: Minimal entry point with clear separation of concerns

### 2. Module Loader (core.sh)

- Manage module loading order
- Set up environment
- Handle initialization
- Provide cleanup

Critical ordering:

```bash
declare -ar MODULE_ORDER=(
    "utils.sh"      # Base utilities (required first)
    "debug.sh"      # Logging system (required early)
    "metrics.sh"    # Metrics tracking
    "config.sh"     # Configuration management
    "validators.sh" # Certificate validation
    "processors.sh" # Certificate processing
    "menu.sh"       # User interface (last)
)
```

### 3. UI Layer (menu.sh)

- Handle all user interaction
- Process commands and flags
- Display help and errors
- Manage configuration display

Command flow:

```
User Input → Parse Args → Command Handler → Module Actions → Output
```

### 4. Implementation Layer (Modules)

- config.sh: State management
- debug.sh: Logging and debugging
- validators.sh: Certificate validation
- processors.sh: Certificate processing
- metrics.sh: Performance tracking
- utils.sh: Shared utilities

## State Management

### Debug State

Three synchronized mechanisms:

1. Environment Variables: DEBUG, CERT_TOOLKIT_DEBUG
2. Configuration: CONFIG[DEBUG]
3. Command Line: --debug flag

See: [Debug Guide](../tech/debug.md) for detailed debug management

### Configuration State

Managed through config.sh with:

- Environment variable integration
- Command line overrides
- Configuration file support
- Validation system

## Command Processing Flow

1. Initial Processing (cert-manager.sh)

   ```
   Parse Debug Flags → Load Core → Process Commands
   ```

2. Command Handling (menu.sh)

   ```
   Parse Args → Validate → Execute → Output
   ```

3. Module Integration

   ```
   Command → Module Action → State Update → Output
   ```

## Testing Architecture

### Test Categories

1. Unit Tests (test/unit/)
   - Module-specific functionality
   - Function isolation
   - State management

2. Integration Tests (test/integration/)
   - Cross-module interaction
   - Command processing
   - State persistence

3. System Tests (test/system/)
   - Full workflow testing
   - Certificate processing
   - Error handling

### Test Support

- test_helper.bats: Common test functions
- fixtures/: Test certificates and configs
- mocks/: Mock functions for isolation

## Error Handling

Standard error flow:

```
Error Detection → Log Error → Update State → User Output → Exit Code
```

Exit codes follow GNU standards:

- 0: Success
- 1: General error
- 2: Invalid usage
- 3: Invalid input
- 4: IO error
- 5: Temp file error

## Future Considerations

See [Development Roadmap](roadmap.md) for detailed future plans.

## Related Documentation

- [Debug System](../tech/debug.md)
- [Testing Guide](../testing/README.md)
- [Contributing Guide](contributing.md)
- [Standards](../standards/README.md)
- [Roadmap](roadmap.md)  # Added reference
