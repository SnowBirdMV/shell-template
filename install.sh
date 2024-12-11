#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print informational messages
info() {
    echo "[INFO] $1"
}

# Function to prompt for password when necessary
sudo_require() {
    sudo -v
    # Keep-alive: update existing sudo time stamp until the script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

info "Starting setup..."

# Ensure zsh is installed
if ! command -v zsh &> /dev/null; then
    info "zsh not found. Installing zsh..."
    sudo_require
    sudo apt update
    sudo apt install -y zsh wget unzip fontconfig
    info "zsh installed successfully."
else
    info "zsh is already installed."
fi

# Set zsh as the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    info "Setting zsh as the default shell..."
    sudo chsh -s "$(which zsh)" "$USER"
    info "Default shell changed to zsh. Please log out and back in for changes to take effect."
else
    info "zsh is already the default shell."
fi

# Clone the shell-template repository if not already cloned
if [ ! -d "$HOME/shell-template" ]; then
    info "Cloning shell-template repository..."
    git clone https://github.com/SnowBirdMV/shell-template.git
else
    info "shell-template repository already exists."
fi

cd shell-template

# Make install.sh executable (if not already)
chmod +x install.sh

# Install zsh-snap (Znap) if not already installed
if [ ! -d "$HOME/.zsh_plugins/zsh-snap" ]; then
    info "Installing zsh-snap (Znap)..."
    git clone https://github.com/marlonrichert/znap ~/.zsh_plugins/zsh-snap
    info "zsh-snap installed successfully."
else
    info "zsh-snap is already installed."
fi

# Symlink configuration files if not already symlinked
info "Symlinking configuration files..."
if [ ! -L "$HOME/.zshrc" ]; then
    ln -sf "$PWD/.zshrc" "$HOME/.zshrc"
    info "Symlinked .zshrc successfully."
else
    info ".zshrc is already symlinked."
fi

if [ ! -L "$HOME/.p10k.zsh" ]; then
    ln -sf "$PWD/.p10k.zsh" "$HOME/.p10k.zsh"
    info "Symlinked .p10k.zsh successfully."
else
    info ".p10k.zsh is already symlinked."
fi

# Install Powerlevel10k via znap if not already installed
if [ ! -d "$HOME/.zsh_plugins/romkatv/powerlevel10k" ]; then
    info "Installing Powerlevel10k prompt..."
    znap source romkatv/powerlevel10k
    info "Powerlevel10k installed successfully."
else
    info "Powerlevel10k is already installed."
fi

# Install JetBrainsMono Nerd Font
info "Installing JetBrainsMono Nerd Font..."
wget -O JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip
unzip -o JetBrainsMono.zip -d ~/.local/share/fonts
fc-cache -fv
rm JetBrainsMono.zip
info "JetBrainsMono Nerd Font installed successfully."

# Install zoxide
if ! command -v zoxide &> /dev/null; then
    info "Installing zoxide..."
    # Download and install zoxide using its official install script
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    info "zoxide installed successfully."
else
    info "zoxide is already installed."
fi

# Install plugins via znap
info "Installing zsh-autosuggestions and fast-syntax-highlighting plugins via znap..."
znap source zsh-users/zsh-autosuggestions
znap source zdharma-continuum/fast-syntax-highlighting
info "Plugins installed successfully."

# Final message
info "Setup complete! Open a new terminal or run 'zsh' to load your new configuration."
info "Don't forget to change your terminal font to a Nerd Font (e.g., JetBrainsMono Nerd Font) for proper icons."
info "Ensure your .zshrc includes the following lines for zoxide:"
echo "  eval \"\$(zoxide init zsh)\""
echo "  alias cd='zoxide cd'"
