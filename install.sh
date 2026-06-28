#!/bin/sh
set -e

echo "🚀 Starting dotfile bootstrap..."

# 1. Prepare permanent dotfiles destination
DOTFILES_DIR="$HOME/dotfiles"
mkdir -p "$DOTFILES_DIR"

# 2. Copy the files from /tmp to their permanent home. 
# This command should be run from the tarball being run and extracted in tmp.
# This copies everything from the running directory into ~/dotfiles
cp -R "$(dirname "$0")/" "$DOTFILES_DIR/"
cd "$DOTFILES_DIR"

# 3. Core Dependency: Install Homebrew if missing and run the brewfile
if ! command -v brew &>/dev/null; then
    echo "🍺 Installing Homebrew..."
    chmod +X "$DOTFILES_DIR/bootstrap/brew_setup.sh"
    "$DOTFILES_DIR/bootstrap/brew_setup.sh"
fi

# 4. GitHub SSH Key Setup
echo "🔑 Setting up GitHub SSH keys and local configuration file..."
chmod +X "$DOTFILES_DIR/bootstrap/github_setup.sh"
"$DOTFILES_DIR/bootstrap/github_setup.sh"

# 5. Configuration Linker: Run GNU Stow
echo "🔗 Symlinking configurations with GNU Stow..."
stow zsh
stow terminal
stow git

echo "🎉 Mac setup complete! Open a new terminal tab to enjoy."
