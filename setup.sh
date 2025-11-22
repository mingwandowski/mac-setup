#!/bin/zsh

set -euo pipefail

divider() {
    echo "----------------------------------------"
}

echo ""
divider
echo ">>> mac-setup — starting"
divider
echo ""

#
# 1. Rosetta (for Apple Silicon)
#
if [[ "$(uname -m)" == "arm64" ]]; then
    if ! /usr/bin/pgrep oahd >/dev/null 2>&1; then
        echo ">>> Installing Rosetta..."
        softwareupdate --install-rosetta --agree-to-license || true
    else
        echo ">>> Rosetta already installed."
    fi
fi

#
# 2. Homebrew
#
echo ">>> Checking Homebrew..."
if ! command -v brew >/dev/null 2>&1 && [ ! -x "/opt/homebrew/bin/brew" ]; then
    echo ">>> Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo ">>> Homebrew already installed."
    if ! command -v brew >/dev/null 2>&1 && [ -x "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

#
# 3. Git Config
#
divider
echo ">>> Git configuration"
divider

read -r -p "Enter Git user.name (leave empty to skip): " GIT_NAME
if [ -n "${GIT_NAME}" ]; then
    git config --global user.name "$GIT_NAME"
    echo "> Set git user.name = $GIT_NAME"
fi

read -r -p "Enter Git user.email (leave empty to skip): " GIT_EMAIL
if [ -n "${GIT_EMAIL}" ]; then
    git config --global user.email "$GIT_EMAIL"
    echo "> Set git user.email = $GIT_EMAIL"
fi
echo ""

#
# 4. SSH key
#
divider
echo ">>> SSH key"
divider

read -r -p "Generate a new SSH key? [y/N]: " GEN_SSH
if [[ "${GEN_SSH}" =~ ^[Yy]$ ]]; then
    read -r -p "Enter SSH key comment (default = git email): " SSH_COMMENT
    SSH_COMMENT="${SSH_COMMENT:-${GIT_EMAIL:-no-comment}}"

    mkdir -p "$HOME/.ssh"
    KEY_PATH="$HOME/.ssh/id_ed25519"
    if [ -f "$KEY_PATH" ]; then
        read -r -p "A key already exists at $KEY_PATH. Overwrite? [y/N]: " OVERWRITE
        if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
            echo "> Skipping key generation (existing key kept)."
        else
            ssh-keygen -t ed25519 -C "$SSH_COMMENT" -f "$KEY_PATH" || true
            echo "> SSH key generated at: $KEY_PATH"
        fi
    else
        ssh-keygen -t ed25519 -C "$SSH_COMMENT" -f "$KEY_PATH" || true
        echo "> SSH key generated at: $KEY_PATH"
    fi

    if [ -f "$KEY_PATH.pub" ]; then
        echo ""
        echo ">>> Public key preview:"
        head -n 5 "$KEY_PATH.pub" || true

        if command -v pbcopy >/dev/null 2>&1; then
            pbcopy < "$KEY_PATH.pub"
            echo "(public key copied to clipboard)"
        fi

        echo "Upload this key to GitHub / GitLab / Bitbucket."
    fi
fi
echo ""

#
# 5. Global gitignore
#
echo ">>> Setting global .gitignore"
grep -qx ".DS_Store" ~/.gitignore_global 2>/dev/null \
    || echo ".DS_Store" >> ~/.gitignore_global

git config --global core.excludesfile ~/.gitignore_global
echo "> Added .DS_Store to global gitignore"
echo ""

#
# 6. VSCode extensions
#
divider
echo ">>> VSCode extensions"
divider

if command -v code >/dev/null 2>&1; then
    if [ -f "./vscode-extensions.txt" ]; then
        echo "Installing from vscode-extensions.txt..."
        while read -r EXT; do
            if [ -n "$EXT" ]; then
                echo "> Installing $EXT"
                code --install-extension "$EXT" || true
            fi
        done < "./vscode-extensions.txt"
    else
        echo "No vscode extensions list found — skipping."
    fi
else
    echo "VSCode not detected — skipping plugin installation."
fi
echo ""

#
# Finish
#
divider
echo ">>> Finished — mac-setup complete 🎉"
divider
echo ""
echo "If you generated an SSH key, remember to add the public key:"
echo "  $HOME/.ssh/id_ed25519.pub"
echo ""