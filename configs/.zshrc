# ~/.zshrc

# Source zsh-snap
source ~/.zsh_plugins/zsh-snap/zsh-snap.zsh

# Load the Powerlevel10k prompt
znap prompt romkatv/powerlevel10k

# Load other plugins
znap eval zsh-users/zsh-autosuggestions 'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"'
znap eval zdharma-continuum/fast-syntax-highlighting

# Source your Powerlevel10k configuration
if [ -f ~/.p10k.zsh ]; then
    source ~/.p10k.zsh
fi
