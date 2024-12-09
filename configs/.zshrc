# ~/.zshrc

# Ensure zsh-snap is installed
if [[ ! -f ${ZDOTDIR:-$HOME}/.zsh_plugins/zsh-snap/zsh-snap.zsh ]]; then
    mkdir -p ${ZDOTDIR:-$HOME}/.zsh_plugins
    git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git ${ZDOTDIR:-$HOME}/.zsh_plugins/zsh-snap
fi

# Source zsh-snap
source ${ZDOTDIR:-$HOME}/.zsh_plugins/zsh-snap/zsh-snap.zsh

# Load the Powerlevel10k prompt
znap prompt romkatv/powerlevel10k

# Load other plugins as needed
znap eval zsh-users/zsh-autosuggestions 'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"'
znap eval zdharma-continuum/fast-syntax-highlighting

# Source Powerlevel10k configuration
if [ -f ~/.p10k.zsh ]; then
    source ~/.p10k.zsh
fi

# Update plugins in the background on new shells
znap update &
