# Contributing Guide

## Quick Start

1. Environment Setup
   See [Development Setup](setup.md) for detailed instructions.

   ```bash
   # Clone repository
   git clone https://github.com/mitre/cert-toolkit.git
   cd cert-toolkit/cert-toolkit-shell

   # Install dependencies
   ./scripts/setup-dev.sh

   # Verify setup
   bats test/00-verify-setup.bats
   ```

2. Development Container

   ```bash
   # Build container
   ./test/docker/build.sh

   # Run tests in container
   ./test/docker/run-container-tests.sh
   ```

## Development Standards

All contributions must follow:

- [Coding Standards](../standards/coding.md)         # Updated from STANDARDS.md
- [Architecture Overview](architecture.md)           # Updated relative path
- [Testing Guide](../testing/README.md)             # Updated from TESTING.md
- [Debug System](../tech/debug.md)                  # Updated from DEBUG.md

## Development Process

1. Create Feature Branch

   ```bash
   git checkout -b feature/descriptive-name
   ```

2. Write Tests First

   ```bash
   # Create test file
   touch test/unit/feature_test.bats

   # Run tests
   bats test/unit/feature_test.bats
   ```

3. Implement Feature
   - Follow module patterns
   - Maintain state properly
   - Document thoroughly

4. Verify Changes

   ```bash
   # Run all tests
   bats test/

   # Run with debug
   DEBUG=true bats test/
   ```

## Pull Request Requirements

### 1. Code Quality

- Shellcheck compliance
- No TODOs in code
- Clear documentation
- Complete test coverage

### 2. Testing

- All tests pass
- New tests added
- Edge cases covered
- Debug state verified

### 3. Documentation

- Update relevant docs
- Add examples
- Clear descriptions
- Version updates

### 4. Review Process

- Self-review first
- Address feedback
- Update tests
- Verify changes

## Code Review Process

### Review Checklist

1. Code Structure
   - Follows module patterns
   - Clear function organization
   - Proper error handling
   - Consistent style

2. Testing Coverage
   - Unit tests complete
   - Integration tests added
   - Edge cases covered
   - Test documentation

3. Documentation
   - Function headers
   - Module description
   - Example usage
   - Updated README

4. Shell Best Practices
   - ShellCheck compliance
   - POSIX compatibility
   - Error handling
   - Debug support

### Review Workflow

1. Initial Review

   ```bash
   # Run automated checks
   ./scripts/pre-review.sh

   # Verify documentation
   ./scripts/verify-docs.sh
   ```

2. Code Quality
   - No TODOs remaining
   - No debug statements
   - Clean git history
   - Proper error messages

3. Performance Check
   - Resource usage
   - Error conditions
   - Large file handling
   - Timeout scenarios

### Common Review Points

1. Security
   - File permissions
   - Input validation
   - Error recovery
   - Secure defaults

2. Maintainability
   - Clear comments
   - Consistent style
   - Modular design
   - Reusable functions

## Release Process

### Version Updates

```bash
# Update version in cert-manager.sh
VERSION="1.0.0"

# Update changelog
# Tag release
git tag -a v1.0.0 -m "Version 1.0.0"
```

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version bumped
- [ ] Changelog updated in ../../CHANGELOG.md    # Updated path
- [ ] Tagged release
- [ ] Release notes

## See Also

- [Development Roadmap](roadmap.md)                 # Updated from future.md
- [Coding Standards](../standards/coding.md)        # Fixed relative path
- [Testing Guide](../testing/README.md)             # Fixed relative path

## Support

- GitHub Issues: Bug reports, features
- Pull Requests: Contributions
- Documentation: Questions
