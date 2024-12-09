# If zsh-snap is not present (e.g., first run), clone it. You can also rely on install.sh to do this.
if [[ ! -f ${ZDOTDIR:-$HOME}/.zsh_plugins/zsh-snap/zsh-snap.zsh ]]; then
    mkdir -p ${ZDOTDIR:-$HOME}/.zsh_plugins
    git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git ${ZDOTDIR:-$HOME}/.zsh_plugins/zsh-snap
fi

# Source zsh-snap
source ${ZDOTDIR:-$HOME}/.zsh_plugins/zsh-snap/zsh-snap.zsh

# Load plugins with zsh-snap
# Syntax: znap <command> <plugin-repo> [<run-command>]
znap prompt romkatv/powerlevel10k
znap eval zsh-users/zsh-autosuggestions 'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"'
znap eval zdharma-continuum/fast-syntax-highlighting

# Source your Powerlevel10k configuration
if [ -f ~/.p10k.zsh ]; then
    source ~/.p10k.zsh
fi

# Run znap update in background
znap update