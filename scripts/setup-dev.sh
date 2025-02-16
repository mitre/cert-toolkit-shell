#!/bin/bash
set -e

# Install development dependencies
install_dev_deps() {
    if command -v apt-get >/dev/null; then
        sudo apt-get update
        sudo apt-get install -y bats shellcheck openssl curl wget zsh
    elif command -v brew >/dev/null; then
        brew install bats-core shellcheck
    else
        echo "Unsupported package manager"
        exit 1
    fi
}

# Setup git hooks
setup_git_hooks() {
    cat >.git/hooks/pre-commit <<'EOF'
#!/bin/bash
shellcheck src/*.sh scripts/*.sh
bats test/*.bats
EOF
    chmod +x .git/hooks/pre-commit
}

# Main
install_dev_deps
setup_git_hooks
