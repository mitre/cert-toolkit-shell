# Documentation Standards

## File Organization

```
docs/
├── user/         # User-facing documentation
├── dev/          # Developer documentation
├── standards/    # Project standards
├── technical/    # Technical details
└── testing/      # Testing documentation
```

## Documentation Types

1. User Documentation
   - Installation guide
   - Command reference
   - Configuration
   - Troubleshooting

2. Developer Documentation
   - Architecture
   - Module system
   - State management
   - Testing guide

3. API Documentation
   - Function headers
   - Module interfaces
   - Return values
   - Examples

## Style Guide

### Headers

```markdown
# Main Title
## Section
### Subsection
#### Detail
```

### Code Blocks

```markdown
\```bash
# Example code
command --option value
\```
```

### Links and References

```markdown
[Link Text](relative/path/to/doc.md)
See: [Related Document](../path/to/doc.md)
```

## Function Documentation

```bash
# Function: name
# Description: Detailed description
# Arguments:
#   $1 - first argument
#   $2 - second argument
# Returns:
#   0 - success
#   1 - error condition
# Examples:
#   name arg1 arg2
```

## Module Documentation

```bash
#!/bin/bash
#
# Module: name
# Purpose: Brief description
# Dependencies:
#   - module1: reason
#   - module2: reason
#
# Usage examples:
#   source module.sh
#   function_name arg1 arg2
```

## README Requirements

1. Project Description
2. Installation Steps
3. Basic Usage
4. Examples
5. Dependencies
6. Contributing
7. License

## Related Documentation

- [Contributing Guide](../dev/contributing.md)  # Updated - includes code review guidelines
- [Architecture](../dev/architecture.md)
- [Testing Guide](../testing/README.md)
