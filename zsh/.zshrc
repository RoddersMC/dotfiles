# --- ZSH // History ---
# Guide: https://github.com/rothgar/mastering-zsh/blob/master/docs/config/history.md

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=10000
SAVEHIST=10000

setopt EXTENDED_HISTORY
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# --- ZSH // Behaviour ---

setopt NUMERIC_GLOB_SORT

# Initialize completion
autoload -U compinit; compinit

# --- Init // Fuzzy Finder ---
source <(fzf --zsh)

# --- Init and Aliasing // Zoxide ---
eval "$(zoxide init zsh)"

if command -V zoxide &>/dev/null; then
    alias cdi='zi'
else
    echo "!ERROR! - zoxide is not installed, please install it."
fi

# --- Aliasing // Eza ---
if command -v eza &>/dev/null; then
    alias ls='eza'
    alias ll='eza -l --header --icons'
    alias la='eza -lah --git  --header --icons --group-directories-first'
    alias lh='eza -Ad .* --header --icons -l'
    alias tree='eza -a --tree --icons'
else
    echo "!ERROR! - eza is not installed, please install it."
fi

# --- Aliasing // drawio export --
if command -v drawio &>/dev/null; then
    alias dts='drawio -rx --format svg --transparent --embed-diagram --output ~/drawio-outputs/'
else
    echo "!ERROR! - drawio is not installed, please install it."
fi

# --- Init // starship ---
eval "$(starship init zsh)"
