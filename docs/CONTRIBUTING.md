# Contributing Guidelines

## Development Setup

1. Clone the repository
2. Run `./scripts/setup-dev.sh`
3. Make changes
4. Run tests: `bats test/*.bats`
5. Submit PR

## Testing

Please ensure all new code has appropriate test coverage. Review our [test plan](test-plan.md) for details on:

- Test organization
- Required test cases
- Mock implementations
- Test fixtures

- Unit tests: `test/test_add_dod_certs.bats`
- Shell compatibility: `test/shell_compatibility.bats`
- Run all tests: `bats test/*.bats`

## Release Process

1. Update version in script
2. Run tests
3. Use `./scripts/release.sh <version>`
