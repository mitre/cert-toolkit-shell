# Contributing to cert-toolkit-shell

## Branch Model

### Main Branch

- `main` - Production-ready code, protected branch

### Feature Branches

Create from `main`, merge back to `main` via pull request:

```bash
git checkout -b feature/description main
```

### Hotfix Branches

Create from `main`, merge back to `main` via pull request:

```bash
git checkout -b hotfix/issue-description main
```

## Workflow

1. Create Feature Branch

```bash
git checkout main
git pull
git checkout -b feature/your-feature
```

2. Keep Current

```bash
# Update your branch with main
git fetch origin
git rebase origin/main
```

3. Develop and Test

```bash
# Make changes
# Add tests
# Run tests
bats test/
```

4. Create Pull Request

```bash
gh pr create --base main --head feature/your-feature
```

## Pull Request Process

1. Ensure all tests pass
2. Update documentation
3. Request review
4. Address feedback
5. Squash and merge to main

See [Development Guide](docs/dev/contributing.md) for detailed standards.

## Development Standards

All contributions must follow our standards:

- [Coding Standards](docs/standards/coding.md)
- [Testing Standards](docs/testing/README.md)
- [Documentation Standards](docs/standards/documentation.md)
- [Security Standards](docs/standards/security.md)
- [Implementation Standards](docs/dev/standardization.md)

## Workflow Examples

### Feature Development

```bash
# Start new feature
git checkout main
git pull
git checkout -b feature/add-cert-validation

# Regular commits
git add src/lib/validators.sh
git commit -m "feat: add certificate validation

- Add chain validation
- Add expiry checking
- Add signature verification
- Add unit tests"

# Update with main
git fetch origin
git rebase origin/main

# Push and create PR
git push -u origin feature/add-cert-validation
gh pr create --base main --head feature/add-cert-validation
```

### Hotfix Process

```bash
# Create hotfix branch
git checkout main
git checkout -b hotfix/fix-cert-parsing

# Fix and test
git add src/lib/processors.sh
git commit -m "fix: correct certificate parsing error

- Fix PEM header detection
- Add regression test
- Update documentation"

# Create PR
gh pr create --base main --head hotfix/fix-cert-parsing --label hotfix
```

### Code Review

```bash
# Address review feedback
git add src/lib/validators.sh
git commit -m "refactor: address review feedback

- Improve error messages
- Add more test cases
- Update documentation"

# Update PR
git push

# After approval, squash and merge via GitHub UI
```

## Development Process

### 1. Code Quality

- ShellCheck compliance
- No TODOs in code
- Clear documentation
- Complete test coverage

### 2. Testing Requirements

- All tests pass
- New tests added
- Edge cases covered
- Debug state verified

### 3. Documentation Updates

- Update relevant docs
- Add examples
- Clear descriptions
- Version updates

### 4. Review Process

- Self-review first
- Address feedback
- Update tests
- Verify changes

## Release Process

### Version Updates

```bash
# Update version in cert-manager.sh
VERSION="1.0.0"

# Tag release
git tag -a v1.0.0 -m "Version 1.0.0"
```

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version bumped
- [ ] Changelog updated
- [ ] Tagged release
- [ ] Release notes created

## Getting Help

- GitHub Issues: Bug reports, features
- Pull Requests: Contributions
- Documentation: Questions

## Additional Resources

- [Development Guide](docs/dev/setup.md)
- [Test Writing Guide](docs/testing/writing-tests.md)
- [External Standards](docs/standards/references.md)

## Related Documentation

- [Development Guide](docs/dev/contributing.md)
- [Testing Guide](docs/testing/README.md)
- [Implementation Standards](docs/dev/standardization.md)
