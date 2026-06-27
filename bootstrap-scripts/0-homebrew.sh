# Install Homebrew

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

# Install packages

packages=(
    bat
    eza
    fzf
    git
    grep
    neovim
    starship
    stow
    tuxedo
    zoxide
    )

brew install "${packages[@]}"

# Install cask packages

casks=(
    google-chrome
    ghostty
    visual-studio-code
    drawio
    excalidrawz
)

brew install "${casks[@]}" --cask
