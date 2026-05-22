# Install Homebrew

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

# Install packages

packages=(
    git
    eza
    fzf
    grep
    neovim
    zoxide
    )

brew install "${packages[@]}"

# Install cask packages

casks=(
    google-chrome
    ghostty
    visual-studio-code
)

brew install "{casks[@]}" --cask
