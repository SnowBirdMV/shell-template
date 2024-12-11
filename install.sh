#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Script directory determined as: $SCRIPT_DIR"

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
    echo "Operating System: macOS"
    # On macOS, ensure Homebrew is installed, then install required packages
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "Homebrew installed successfully."
    else
        echo "Homebrew is already installed."
    fi
    echo "Installing required packages via Homebrew..."
    # Install tools: zsh, git, wget, unzip, fontconfig, zoxide, lsd
    brew install zsh git wget unzip fontconfig zoxide lsd
    echo "Required packages installed via Homebrew."
else
    echo "Operating System: Linux/Ubuntu"
    # On Ubuntu/Debian
    echo "Updating apt and installing required packages..."
    sudo_require
    sudo apt update
    sudo apt install -y zsh git wget unzip fontconfig curl
    echo "Required packages installed via apt."

    # Install the latest lsd
    echo "Installing the latest lsd..."
    # Download the latest lsd .deb package
    LSD_DEB_URL=$(curl -s https://api.github.com/repos/Peltoche/lsd/releases/latest | grep "browser_download_url.*lsd-linux-musl.deb" | cut -d '"' -f 4)
    wget -q "$LSD_DEB_URL" -O /tmp/lsd.deb
    # Install the downloaded .deb package
    sudo dpkg -i /tmp/lsd.deb || sudo apt install -f -y
    # Clean up
    rm /tmp/lsd.deb
    echo "lsd installed successfully."
fi

# Ensure zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "zsh installation failed. Please install zsh and re-run the script."
    exit 1
fi
echo "zsh is installed."

# Set zsh as the default shell
CURRENT_SHELL="$(basename "$SHELL")"
ZSH_PATH="$(command -v zsh)"
echo "Current shell: $CURRENT_SHELL"
echo "zsh path: $ZSH_PATH"

if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "Changing default shell to zsh..."
    sudo chsh -s "$ZSH_PATH" "$USER"
    echo "Default shell changed to zsh. Please log out and back in for changes to take effect."
else
    echo "zsh is already the default shell."
fi

# Install zsh-snap if not already installed
ZSH_SNAP_DIR="$HOME/.zsh_plugins/zsh-snap"
if [ ! -d "$ZSH_SNAP_DIR" ]; then
    echo "Installing zsh-snap..."
    git clone https://github.com/marlonrichert/zsh-snap.git "$ZSH_SNAP_DIR"
    echo "zsh-snap installed successfully."
else
    echo "zsh-snap is already installed."
fi

# Verify that configs/.zshrc and configs/.p10k.zsh exist
ZSHRC_SOURCE="$SCRIPT_DIR/configs/.zshrc"
P10K_SOURCE="$SCRIPT_DIR/configs/.p10k.zsh"

echo "Verifying existence of configuration files..."
if [ ! -f "$ZSHRC_SOURCE" ]; then
    echo "Error: $ZSHRC_SOURCE does not exist."
    exit 1
fi

if [ ! -f "$P10K_SOURCE" ]; then
    echo "Error: $P10K_SOURCE does not exist."
    exit 1
fi
echo "Configuration files verified."

# Backup existing .zshrc and .p10k.zsh if they are regular files
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc to .zshrc.backup..."
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi

if [ -f "$HOME/.p10k.zsh" ] && [ ! -L "$HOME/.p10k.zsh" ]; then
    echo "Backing up existing .p10k.zsh to .p10k.zsh.backup..."
    cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.backup"
fi

# Remove existing .zshrc and .p10k.zsh if they exist (whether regular files or symlinks)
if [ -e "$HOME/.zshrc" ] || [ -L "$HOME/.zshrc" ]; then
    echo "Removing existing .zshrc..."
    rm -f "$HOME/.zshrc"
    echo ".zshrc removed."
fi

if [ -e "$HOME/.p10k.zsh" ] || [ -L "$HOME/.p10k.zsh" ]; then
    echo "Removing existing .p10k.zsh..."
    rm -f "$HOME/.p10k.zsh"
    echo ".p10k.zsh removed."
fi

# Symlink configuration files
echo "Creating symlink for .zshrc..."
ln -s "$ZSHRC_SOURCE" "$HOME/.zshrc"
echo "Symlink for .zshrc created: $(ls -l "$HOME/.zshrc")"

echo "Creating symlink for .p10k.zsh..."
ln -s "$P10K_SOURCE" "$HOME/.p10k.zsh"
echo "Symlink for .p10k.zsh created: $(ls -l "$HOME/.p10k.zsh")"

# Verify symlinks
echo "Verifying symlinks..."
if [ -L "$HOME/.zshrc" ] && [ "$(readlink "$HOME/.zshrc")" == "$ZSHRC_SOURCE" ]; then
    echo ".zshrc is correctly symlinked to $ZSHRC_SOURCE."
else
    echo "Error: Failed to symlink .zshrc." >&2
    exit 1
fi

if [ -L "$HOME/.p10k.zsh" ] && [ "$(readlink "$HOME/.p10k.zsh")" == "$P10K_SOURCE" ]; then
    echo ".p10k.zsh is correctly symlinked to $P10K_SOURCE."
else
    echo "Error: Failed to symlink .p10k.zsh." >&2
    exit 1
fi

# Remove existing .zshrc.zwc if it exists
if [ -f "$HOME/.zshrc.zwc" ]; then
    echo "Removing existing .zshrc.zwc..."
    rm "$HOME/.zshrc.zwc"
    echo ".zshrc.zwc removed."
fi

# Ensure $HOME/.local/bin is on PATH for the script
export PATH="$HOME/.local/bin:$PATH"
echo "Updated PATH for the script: $PATH"

# Install zoxide if not installed
if ! command -v zoxide &> /dev/null; then
    echo "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    echo "zoxide installed successfully."
else
    echo "zoxide is already installed."
fi

# Install Powerlevel10k prompt if not installed
P10K_DIR="$HOME/.zsh_plugins/romkatv/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "Installing Powerlevel10k..."
    zsh -ic 'znap source romkatv/powerlevel10k'
    echo "Powerlevel10k installed successfully."
else
    echo "Powerlevel10k is already installed."
fi

# Install zsh-autosuggestions and fast-syntax-highlighting via znap
echo "Installing zsh-autosuggestions and fast-syntax-highlighting..."
zsh -ic 'znap source zsh-users/zsh-autosuggestions; znap source zdharma-continuum/fast-syntax-highlighting'
echo "zsh-autosuggestions and fast-syntax-highlighting installed successfully."

# Install zsh-lsd via znap
echo "Installing zsh-lsd..."
zsh -ic 'znap source z-shell/zsh-lsd'
echo "zsh-lsd installed successfully."

# Install JetBrainsMono Nerd Font
echo "Installing JetBrainsMono Nerd Font..."
FONT_ZIP="JetBrainsMono.zip"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
wget -q -O "$FONT_ZIP" "$FONT_URL"
echo "Downloaded JetBrainsMono Nerd Font."

unzip -o "$FONT_ZIP" -d "$HOME/.local/share/fonts"
echo "Extracted JetBrainsMono Nerd Font to $HOME/.local/share/fonts."

fc-cache -fv >/dev/null 2>&1
echo "Font cache updated."

rm "$FONT_ZIP"
echo "Cleaned up downloaded font zip."

# Final message
echo "========================================"
echo "Setup complete!"
echo "Open a new terminal or run 'zsh' to load your new configuration."
echo "Don't forget to change your terminal font to JetBrainsMono Nerd Font for proper icons."
echo "========================================"
