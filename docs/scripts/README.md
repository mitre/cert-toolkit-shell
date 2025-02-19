# Documentation Maintenance Scripts

Utility scripts for maintaining documentation consistency and structure.

## Available Scripts

### doc-case-convert.sh

Converts documentation filenames to consistent lowercase format.

```bash
# Run from docs directory
./scripts/doc-case-convert.sh
```

Preserves:

- README.md files (keeps uppercase)
- Directory structure
- Git history through git mv
