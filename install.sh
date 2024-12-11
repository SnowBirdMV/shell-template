#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Enable debugging (optional, remove in production)
# set -x

# Define the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Function to prompt for password when necessary
sudo_require() {
    sudo -v
    # Keep-alive: update existing sudo time stamp until the script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# Start setup
echo "Starting setup..."

# Determine OS type and install necessary packages
if [[ "$OSTYPE" == "darwin"* ]]; then
    # On macOS, ensure Homebrew is installed, then install required packages
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    echo "Installing required packages via Homebrew..."
    brew install zsh git wget unzip fontconfig zoxide
else
    # On Ubuntu/Debian
    echo "Updating apt and installing required packages..."
    sudo_require
    sudo apt update
    sudo apt install -y zsh git wget unzip fontconfig curl
fi

# Ensure zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "zsh installation failed. Please install zsh and re-run the script."
    exit 1
fi

# Set zsh as the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to zsh..."
    sudo chsh -s "$(which zsh)" "$USER"
    echo "Default shell changed to zsh. Please log out and back in for changes to take effect."
fi

# Install zsh-snap if not already installed
if [ ! -d "$HOME/.zsh_plugins/zsh-snap" ]; then
    echo "Installing zsh-snap..."
    git clone https://github.com/marlonrichert/zsh-snap.git "$HOME/.zsh_plugins/zsh-snap"
fi

# Verify that configs/.zshrc and configs/.p10k.zsh exist
if [ ! -f "$SCRIPT_DIR/configs/.zshrc" ]; then
    echo "Error: $SCRIPT_DIR/configs/.zshrc does not exist."
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/configs/.p10k.zsh" ]; then
    echo "Error: $SCRIPT_DIR/configs/.p10k.zsh does not exist."
    exit 1
fi

# Remove existing .zshrc and .p10k.zsh if they exist (whether regular files or symlinks)
if [ -e "$HOME/.zshrc" ]; then
    echo "Removing existing .zshrc..."
    rm -f "$HOME/.zshrc"
fi

if [ -e "$HOME/.p10k.zsh" ]; then
    echo "Removing existing .p10k.zsh..."
    rm -f "$HOME/.p10k.zsh"
fi

# Symlink configuration files
echo "Creating symlink for .zshrc..."
ln -sf "$SCRIPT_DIR/configs/.zshrc" "$HOME/.zshrc"
echo "Creating symlink for .p10k.zsh..."
ln -sf "$SCRIPT_DIR/configs/.p10k.zsh" "$HOME/.p10k.zsh"

# Verify symlinks
if [ -L "$HOME/.zshrc" ]; then
    echo ".zshrc is correctly symlinked."
else
    echo "Failed to symlink .zshrc." >&2
    exit 1
fi

if [ -L "$HOME/.p10k.zsh" ]; then
    echo ".p10k.zsh is correctly symlinked."
else
    echo "Failed to symlink .p10k.zsh." >&2
    exit 1
fi

# Remove existing .zshrc.zwc if it exists
if [ -f "$HOME/.zshrc.zwc" ]; then
    echo "Removing existing .zshrc.zwc..."
    rm "$HOME/.zshrc.zwc"
fi

# Ensure $HOME/.local/bin is on PATH in .zshrc
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc"; then
    echo 'Adding $HOME/.local/bin to PATH in .zshrc...'
    sed -i '1i export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc"
fi

# Ensure eval "$(zoxide init zsh)" is in .zshrc
if ! grep -q 'eval "$(zoxide init zsh)"' "$HOME/.zshrc"; then
    echo 'Adding zoxide initialization to .zshrc...'
    echo 'eval "$(zoxide init zsh)"' >> "$HOME/.zshrc"
fi

# Ensure $HOME/.local/bin is on PATH for the script
export PATH="$HOME/.local/bin:$PATH"

# Install zoxide if not installed
if ! command -v zoxide &> /dev/null; then
    echo "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# Install Powerlevel10k prompt if not installed
if [ ! -d "$HOME/.zsh_plugins/romkatv/powerlevel10k" ]; then
    echo "Installing Powerlevel10k..."
    zsh -ic 'znap source romkatv/powerlevel10k'
fi

# Install zsh-autosuggestions and fast-syntax-highlighting via znap
echo "Installing zsh-autosuggestions and fast-syntax-highlighting..."
zsh -ic 'znap source zsh-users/zsh-autosuggestions; znap source zdharma-continuum/fast-syntax-highlighting'

# Install JetBrainsMono Nerd Font
echo "Installing JetBrainsMono Nerd Font..."
FONT_ZIP="JetBrainsMono.zip"
wget -q -O "$FONT_ZIP" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip
unzip -o "$FONT_ZIP" -d "$HOME/.local/share/fonts"
fc-cache -fv
rm "$FONT_ZIP"

# Final message
echo "Setup complete! Open a new terminal or run 'zsh' to load your new configuration."
echo "Don't forget to change your terminal font to JetBrainsMono Nerd Font for proper icons."
