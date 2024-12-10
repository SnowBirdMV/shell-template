# Enable Powerlevel10k instant prompt if desired
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Disable P10K configuration wizard
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Source zsh-snap (Znap)
source "${ZDOTDIR:-$HOME}/.zsh_plugins/zsh-snap/znap.zsh"

# Source your custom Powerlevel10k configuration before loading the prompt
# so that all variables are set by the time the prompt initializes.
if [ -f ~/.p10k.zsh ]; then
    source ~/.p10k.zsh
fi

# Now load the Powerlevel10k prompt with your custom config in place
znap prompt romkatv/powerlevel10k

# Load other plugins
znap eval zsh-users/zsh-autosuggestions 'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"'
znap eval zdharma-continuum/fast-syntax-highlighting
