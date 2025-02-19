# Test Workflow Guide

## Pre-commit Tests

```bash
# Quick validation
./scripts/pre-commit.sh

# Full test suite
bats test/
```

## CI/CD Pipeline

1. Unit Tests
2. Integration Tests
3. Performance Tests
4. Security Checks

## Test Data Management

- Certificate fixtures
- Configuration samples
- Error scenarios
- Performance data

## Related Documentation

- [Test Framework](framework.md)                    # Fixed relative path
- [Test Categories](categories.md)                 # Added missing reference
- [Contributing Guide](../dev/contributing.md)      # Fixed relative path
- [Development Setup](../dev/setup.md)             # Updated from old path
