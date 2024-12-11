# Add $HOME/.local/bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Enable Powerlevel10k instant prompt at the top if available
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Disable Powerlevel10k configuration wizard
POWERLEVEL10K_DISABLE_CONFIGURATION_WIZARD=true

# Source znap (plugin manager)
source "${ZDOTDIR:-$HOME}/.zsh_plugins/zsh-snap/znap.zsh"

# Set environment variables before sourcing plugins
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"

# Source Powerlevel10k theme correctly without using 'znap prompt'
znap source romkatv/powerlevel10k

# Set the theme to Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Source zsh-autosuggestions plugin
znap source zsh-users/zsh-autosuggestions

# Source fast-syntax-highlighting plugin
znap source zdharma-continuum/fast-syntax-highlighting

# Source zsh-lsd plugin
znap source z-shell/zsh-lsd

# Initialize zoxide
eval "$(zoxide init zsh)"

# Alias 'cd' to zoxide's 'cd' command
alias cd='z'

# Load your Powerlevel10k configuration if it exists
if [ -f ~/.p10k.zsh ]; then
    source ~/.p10k.zsh
fi
