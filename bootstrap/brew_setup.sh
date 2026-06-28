#!/bin/bash

echo "Checking Homebrew status..."
BUNDLE_FILE="$HOME/dotfiles/bootstrap/brewfile"

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing now..."
    # The installation script handles the password prompts and directory setups safely
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Load it into the current script session so you can use it immediately below
    if [[ -d /opt/homebrew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrew is already installed."
fi

# Now you can safely install packages using your Brewfile
if [ -f "$BUNDLE_FILE" ]; then
    brew update
    brew upgrade

    echo "Installing packages from Brewfile... $BUNDLE_FILE"
    brew bundle --file="$BUNDLE_FILE"
fi
