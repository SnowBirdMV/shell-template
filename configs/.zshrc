# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Disable P10K configuration wizard
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Source znap (zsh-snap)
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