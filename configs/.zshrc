# Enable Powerlevel10k instant prompt at the top if you have it
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Disable Powerlevel10k configuration wizard
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Source znap
source "${ZDOTDIR:-$HOME}/.zsh_plugins/zsh-snap/znap.zsh"

# Load Powerlevel10k prompt
# (Your .p10k.zsh should be sourced after the prompt is loaded if you're not reloading the prompt)
if [ -f ~/.p10k.zsh ]; then
    source ~/.p10k.zsh
fi
znap prompt romkatv/powerlevel10k

# Set zsh-autosuggestions style before loading it
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
znap source zsh-users/zsh-autosuggestions

# Load fast-syntax-highlighting
znap source zdharma-continuum/fast-syntax-highlighting
