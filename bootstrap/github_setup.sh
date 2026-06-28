#!/bin/sh

set -e

echo "👤 --- Git Profile Setup ---"

# Prompt for identity details
read -p "Enter your full name (for Git commits): " user_name
read -p "Enter your GitHub email address: " user_email

if [ -z "$user_name" ] || [ -z "$user_email" ]; then
    echo "❌ Name or Email cannot be empty. Skipping Git configuration."
else
    # Generate the private local Git configuration file securely
    echo "✍️  Writing private credentials to ~/.gitconfig.local..."
    
    echo "[user]" > "$HOME/.gitconfig.local"
    echo "    name = $user_name" >> "$HOME/.gitconfig.local"
    echo "    email = $user_email" >> "$HOME/.gitconfig.local"
    
    echo "✅ ~/.gitconfig.local created successfully!"
fi

echo "🔑 --- SSH Key Verification ---"

KEY_PATH="$HOME/.ssh/id_ed25519"

# Check if the file already exists on the system
if [ -f "$KEY_PATH" ]; then
    echo "⚠️  An SSH key already exists at: $KEY_PATH"
    
    # Prompt the user for explicit confirmation to overwrite
    read -p "Do you want to overwrite it and create a new one? (y/N): " overwrite_choice
    
    # Convert input to lowercase to catch 'Y' or 'y'
    case "$overwrite_choice" in
        [yY][eE][sS]|[yY]) 
            echo "🔄 Overwriting existing key..."
            ;;
        *)
            echo "⏭️  Skipping key generation. Keeping current SSH key."
            # Automatically copy your existing public key to your clipboard anyway
            if [ -f "${KEY_PATH}.pub" ]; then
                cat "${KEY_PATH}.pub" | pbcopy
                echo "📋 Existing public key copied to your clipboard!"
            fi
            # Return early out of this block/function without creating a new key
            return 0 2>/dev/null || exit 0
            ;;
    esac
fi

# --- Standard Generation Logic Runs Below If No Key Existed or User Selected 'Yes' ---
read -p "Enter your GitHub email address: " user_email

if [ -z "$user_email" ]; then
    echo "❌ Email cannot be empty. Skipping SSH key generation."
else
    echo "⏳ Generating Ed25519 SSH key for $user_email..."
    # The -q flag silences the keygen, but it will still prompt you for a passphrase
    ssh-keygen -t ed25519 -C "$user_email" -f "$KEY_PATH"
    
    # Start agent and configure (as shown in the previous step)
    eval "$(ssh-agent -s)"
    mkdir -p "$HOME/.ssh"
    
    # Check if host configuration already exists to prevent duplicate text blocks
    if ! grep -q "Host github.com" "$HOME/.ssh/config" 2>/dev/null; then
        echo "" >> "$HOME/.ssh/config"
        echo "Host github.com" >> "$HOME/.ssh/config"
        echo "  AddKeysToAgent yes" >> "$HOME/.ssh/config"
        echo "  UseKeychain yes" >> "$HOME/.ssh/config"
        echo "  IdentityFile ~/.ssh/id_ed25519" >> "$HOME/.ssh/config"
    fi

    ssh-add --apple-use-keychain "$KEY_PATH"
    cat "${KEY_PATH}.pub" | pbcopy
    echo "✅ New SSH key created and copied to clipboard!"
fi