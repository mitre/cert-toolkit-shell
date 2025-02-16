# Development Environment Setup

## Quick Start

```bash
# Clone repository
git clone https://github.com/mitre/cert-toolkit.git
cd cert-toolkit/cert-toolkit-shell

# Run setup script (handles all dependencies)
./scripts/setup-dev.sh

# Reload shell configuration
source ~/.zshrc  # or ~/.bash_profile

# Verify setup
bats test/00-verify-setup.bats
```

## What the Setup Script Does

### On macOS

- Installs Homebrew (if needed)
- Installs required packages (bats-core, coreutils, etc.)
- Configures PATH for GNU tools
- Sets up BATS test environment
- Configures shell environment

### On Linux

- Installs required packages
- Sets up BATS test environment
- Configures test dependencies

## Verifying Installation

After running setup-dev.sh and reloading your shell:

```bash
# Verify environment
bats test/00-verify-setup.bats
```

## Troubleshooting

If you encounter issues after setup:

1. Verify shell configuration was reloaded:

   ```bash
   source ~/.zshrc  # or ~/.bash_profile
   ```

2. Run setup script with debug output:

   ```bash
   DEBUG=true ./scripts/setup-dev.sh
   ```

3. Check the setup logs:

   ```bash
   less ~/.cert-toolkit-setup.log
   ```

For detailed testing information, see [test-plan.md](test-plan.md)
