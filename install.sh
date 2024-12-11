#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

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
    brew install zsh git wget unzip fontconfig zoxide >/dev/null 2>&1
else
    # On Ubuntu/Debian
    echo "Updating apt and installing required packages..."
    sudo_require
    sudo apt update >/dev/null 2>&1
    sudo apt install -y zsh git wget unzip fontconfig curl >/dev/null 2>&1
fi

# Ensure zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "zsh installation failed. Please install zsh and re-run the script."
    exit 1
fi

# Set zsh as the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s "$(which zsh)" "$USER" >/dev/null 2>&1
    echo "Default shell changed to zsh. Please log out and back in for changes to take effect."
fi

# Install zsh-snap if not already installed
if [ ! -d "$HOME/.zsh_plugins/zsh-snap" ]; then
    git clone https://github.com/marlonrichert/zsh-snap.git "$HOME/.zsh_plugins/zsh-snap" >/dev/null 2>&1
fi

# Symlink configuration files (force symlink)
ln -sf "$(pwd)/configs/.zshrc" "$HOME/.zshrc" >/dev/null 2>&1
ln -sf "$(pwd)/configs/.p10k.zsh" "$HOME/.p10k.zsh" >/dev/null 2>&1

# Remove existing .zshrc.zwc if it exists
if [ -f "$HOME/.zshrc.zwc" ]; then
    rm "$HOME/.zshrc.zwc"
fi

# Ensure $HOME/.local/bin is on PATH in .zshrc
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc"; then
    # Insert at the top of .zshrc
    sed -i '1i export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc"
fi

# Ensure eval "$(zoxide init zsh)" is in .zshrc
if ! grep -q 'eval "$(zoxide init zsh)"' "$HOME/.zshrc"; then
    echo 'eval "$(zoxide init zsh)"' >> "$HOME/.zshrc"
fi

# Install Powerlevel10k prompt if not installed
if [ ! -d "$HOME/.zsh_plugins/romkatv/powerlevel10k" ]; then
    zsh -ic 'znap source romkatv/powerlevel10k' >/dev/null 2>&1
fi

# Install JetBrainsMono Nerd Font
FONT_ZIP="JetBrainsMono.zip"
wget -q -O "$FONT_ZIP" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip
unzip -o "$FONT_ZIP" -d "$HOME/.local/share/fonts" >/dev/null 2>&1
fc-cache -fv >/dev/null 2>&1
rm "$FONT_ZIP"

# Install zoxide if not installed
if ! command -v zoxide &> /dev/null; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash >/dev/null 2>&1
fi

# Install plugins via znap
zsh -ic 'znap source zsh-users/zsh-autosuggestions; znap source zdharma-continuum/fast-syntax-highlighting' >/dev/null 2>&1

# Final message
echo "Setup complete! Open a new terminal or run 'zsh' to load your new configuration."
echo "Don't forget to change your terminal font to JetBrainsMono Nerd Font for proper icons."
