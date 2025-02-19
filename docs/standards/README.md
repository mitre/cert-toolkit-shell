# Project Standards Overview

## Core Standards

1. [Coding Standards](coding.md)
   - Shell scripting guidelines
   - Style rules
   - Module system
   - Error handling

2. [Documentation Standards](documentation.md)
   - File organization
   - Documentation types
   - Style guide
   - API documentation

3. [Security Standards](security.md)
   - Certificate handling
   - File security
   - Input validation
   - Error recovery

## Standards Documentation

1. [Coding Standards](coding.md)
2. [Documentation Standards](documentation.md)
3. [Security Standards](security.md)
4. [External Standards & References](references.md)  # Added new reference

## Standards Compliance

### Shell Script Standards

- Google Shell Style Guide
- GNU Coding Standards
- POSIX Shell Guidelines
- ShellCheck Rules

### Command Line Standards

- GNU Program Behavior
- POSIX Utility Guidelines
- Command Line Interface Guidelines (CLIG)

### Documentation Standards

- Markdown syntax
- Man page format
- API documentation
- Change logs

### Testing Standards

- Test organization
- Naming conventions
- Coverage requirements
- Test isolation

## How to Apply Standards

1. New Code

   ```bash
   # 1. Check coding standards
   shellcheck script.sh
   
   # 2. Run test suite
   bats test/
   
   # 3. Verify documentation
   ./scripts/verify-docs.sh
   ```

2. Code Review
   - Use review checklist
   - Verify standards compliance
   - Check documentation updates
   - Validate tests

## Additional Standards

Merged from original STANDARDS.md:

### Command Line Standards

All commands must follow:

- GNU Program Standards
- POSIX Utility Guidelines
- CLIG Guidelines

### Error Handling Standards

```bash
# Standard error format
program: error: detailed message
Try 'program --help' for more information.
```

### Exit Code Standards

```bash
0  # Success
1  # General error
2  # Invalid usage
3  # Invalid input
4  # IO error
5  # Temp file error
```

## References

- [Google Style Guide](https://google.github.io/styleguide/shellguide.html)
- [GNU Standards](https://www.gnu.org/prep/standards/)
- [POSIX Shell](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
- [CLIG](https://clig.dev/)

## Related Documentation

- [Contributing](../../CONTRIBUTING.md)     # Updated path
- [Architecture](../dev/architecture.md)
- [Testing](../testing/README.md)
- [Debug System](../tech/debug.md)
