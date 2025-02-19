# Development Context

## Project Structure

Base Path: `/Users/alippold/github/mitre/cert-toolkit/cert-toolkit-shell`

### Critical Files

- src/cert-manager.sh (Main entry point)
- src/lib/core.sh (Module loader)
- src/lib/config.sh (Configuration system)
- src/lib/debug.sh (Debug/logging system)
- src/lib/menu.sh (Command handling)
- src/lib/metrics.sh (Statistics tracking)
- src/lib/processors.sh (Certificate processing)
- src/lib/validators.sh (Certificate validation)

## Module Dependencies

- cert-manager.sh → core.sh → all modules
- debug.sh → config.sh (critical debug initialization)
- menu.sh → config.sh (command handling)
- processors.sh → validators.sh (certificate processing)

## Implementation Flow

1. Entry Point (cert-manager.sh)
   - Process debug flags
   - Load core module
   - Initialize environment
   - Process commands

2. Core Loading (core.sh)
   - Set up environment
   - Load modules in order
   - Initialize state
   - Handle cleanup

3. Command Processing (menu.sh)
   - Parse arguments
   - Process options
   - Execute commands
   - Handle errors

4. State Management
   - Debug state (debug.sh)
   - Configuration (config.sh)
   - Command state (menu.sh)
   - Processing state (processors.sh)

## Testing Requirements

See [Test Matrix](../testing/test-matrix.md) for detailed test plans.

## Standards Compliance

See [Implementation Standards](standardization.md) for requirements.

## Related Documentation

- [Architecture Overview](architecture.md)
- [Module System](../tech/modules.md)
- [Progress Report](progress.md)
- [Debug Guide](../tech/debug.md)
- [Menu System](../tech/menu.md)
- [Configuration](../tech/config.md)
