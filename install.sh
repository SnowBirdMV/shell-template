#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

#####################################
# Helper functions
#####################################
function info {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

function warn {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

function error {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
    exit 1
}

function is_macos {
    [[ "$(uname)" == "Darwin" ]]
}

function is_ubuntu {
    if [ -f "/etc/os-release" ]; then
        . /etc/os-release
        [[ "$ID" == "ubuntu" ]]
    else
        return 1
    fi
}

#####################################
# Install zsh if needed
#####################################
function install_zsh {
    if ! command -v zsh &>/dev/null; then
        info "zsh not found. Installing zsh..."
        if is_macos; then
            if ! command -v brew &>/dev/null; then
                info "Homebrew not installed. Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install zsh
        elif is_ubuntu; then
            sudo apt update
            sudo apt install -y zsh wget unzip fontconfig
        else
            error "Unsupported OS. Only macOS and Ubuntu are supported."
        fi
    else
        info "zsh is already installed."
        if is_ubuntu; then
            sudo apt update
            sudo apt install -y wget unzip fontconfig
        fi
    fi
}

#####################################
# Set zsh as the default shell
#####################################
function set_default_shell_to_zsh {
    local zsh_path
    zsh_path="$(which zsh)"

    if [[ "$SHELL" != "$zsh_path" ]]; then
        info "Setting zsh as the default shell..."
        if ! grep -q "$zsh_path" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells
        fi
        chsh -s "$zsh_path"
        info "Default shell changed to zsh. Please log out and back in for changes to take effect."
    else
        info "zsh is already the default shell."
    fi
}

#####################################
# Install zsh-snap (Znap)
#####################################
function install_znap {
    local znap_dir="$HOME/.zsh_plugins/zsh-snap"
    if [ ! -d "$znap_dir" ]; then
        info "Installing zsh-snap (Znap)..."
        mkdir -p "${HOME}/.zsh_plugins"
        git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git "$znap_dir"
    else
        info "zsh-snap is already installed. Pulling latest..."
        (cd "$znap_dir" && git pull)
    fi
}

#####################################
# Install Nerd Font for P10K Icons
#####################################
function install_nerd_font {
    info "Installing JetBrainsMono Nerd Font..."
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts

    if [ ! -f "JetBrains Mono Regular Nerd Font Complete.ttf" ] && [ ! -f "JetBrainsMono-Regular Nerd Font Complete.ttf" ]; then
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip
        unzip JetBrainsMono.zip
        rm JetBrainsMono.zip
        fc-cache -fv
    else
        info "Nerd Font already installed."
    fi
    cd - > /dev/null
}

#####################################
# Symlink configuration files
#####################################
function symlink_configs {
    info "Symlinking configuration files..."
    local CONFIG_DIR="$(pwd)/configs"
    local FILES=(
        ".zshrc"
        ".p10k.zsh"
    )

    for file in "${FILES[@]}"; do
        local target="$HOME/$file"
        if [ -e "$target" ] || [ -h "$target" ]; then
            info "Backing up existing $target to $target.bak"
            mv "$target" "$target.bak"
        fi
        ln -s "$CONFIG_DIR/$file" "$target"
        info "Symlinked $file to $target"
    done
}

#####################################
# Force plugin installation
#####################################
function force_plugin_install {
    info "Forcing plugin installation via znap pull..."
    zsh -i -c "source ~/.zsh_plugins/zsh-snap/znap.zsh && znap pull" || {
        error "Failed to run znap pull. Please ensure zsh-snap is installed correctly."
    }
}

#####################################
# Main
#####################################
function main {
    info "Starting setup..."
    install_zsh
    set_default_shell_to_zsh
    install_znap
    install_nerd_font
    symlink_configs
    force_plugin_install
    info "Setup complete! Open a new terminal or run 'zsh' to load your new configuration."
    info "Don't forget to change your terminal font to a Nerd Font (e.g., JetBrainsMono Nerd Font) for proper icons."
}

main
