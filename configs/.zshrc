# ~/.zshrc

# Source znap
source "${ZDOTDIR:-$HOME}/.zsh_plugins/zsh-snap/znap.zsh"

# Load the Powerlevel10k prompt
znap prompt romkatv/powerlevel10k

# Load other plugins
znap eval zsh-users/zsh-autosuggestions 'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"'
znap eval zdharma-continuum/fast-syntax-highlighting

# Source Powerlevel10k configuration if present
if [ -f ~/.p10k.zsh ]; then
    source ~/.p10k.zsh
fi
