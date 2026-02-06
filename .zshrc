# -------------------------------
# Oh My Zsh setup
# -------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    z
    azure
    fzf-tab
    kubectl
    helm
)

source $ZSH/oh-my-zsh.sh

# -------------------------------
# History settings
# -------------------------------
setopt histignorealldups sharehistory
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# -------------------------------
# pyenv setup
# -------------------------------
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
export POETRY_PYTHON="$(pyenv which python 2>/dev/null || echo python)"

# -------------------------------
# Completion system
# -------------------------------
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit
compinit

unsetopt menu_complete
unsetopt complete_in_word

zstyle ':completion:*' verbose false
zstyle ':completion:*' auto-description ''
zstyle ':completion:*:*:git-add:*' ignored-patterns '*.o' '*.pyc'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' file-sort name
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list ''
zstyle ':completion:*' completer _complete _ignored
zstyle ':completion:*' expand-prefix true
zstyle ':completion:*' special-chars ''
zstyle ':completion:*' menu no

# fzf-tab settings
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' continuous-trigger 'tab'
zstyle ':fzf-tab:*' accept-line tab

# -------------------------------
# Environment variables & aliases
# -------------------------------
export LANG=en_US.UTF-8
export EDITOR=vim
alias k=kubectl
alias cat=bat
alias ls=eza
alias ll="eza -lh --time-style=long-iso -smodified -r"

source <(kubectl completion zsh)
compdef k=kubectl

# -------------------------------
# Prompt setup: full path + git status
# -------------------------------
setopt PROMPT_SUBST

git_prompt_info() {
    local branch
    branch=$(git symbolic-ref --quiet HEAD 2>/dev/null) || return
    branch=${branch#refs/heads/}

    local color
    if git diff --quiet --ignore-submodules -- 2>/dev/null && git diff --cached --quiet --ignore-submodules -- 2>/dev/null; then
        color="%F{green}"   # clean
    else
        color="%F{red}"     # dirty
    fi

    local ahead behind extra=""
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
        ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
        behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)
        [[ $ahead -gt 0 ]] && extra+="↑$ahead"
        [[ $behind -gt 0 ]] && extra+="↓$behind"
    fi

    echo "${color}(${branch}${extra})%f"
}

PROMPT='%F{cyan}${PWD}%f $(git_prompt_info) %# '

# -------------------------------
# vi mode & keybindings
# -------------------------------
bindkey -v
bindkey -M viins 'kj' vi-cmd-mode
bindkey -M visual 'kj' vi-cmd-mode
bindkey -M viins '^[v' edit-command-line
bindkey -M vicmd '^[v' edit-command-line

# ================================
# Optimized fzf-history-widget for Zsh
# ================================
fzf-history-widget() {
  local hist cmd
  # Get history as array, newest first
  hist=("${(@)history[@]}")      # all history entries, no numbers
  hist=("${(@)hist:#}")          # remove empty lines

  # Remove duplicates while preserving order
  typeset -A seen
  cmd=()
  for h in "${hist[@]}"; do
    [[ -n $h && -z ${seen[$h]} ]] && cmd+=("$h") && seen[$h]=1
  done

  # Launch fzf
  local selected
  selected=$(printf '%s\n' "${cmd[@]}" | fzf --reverse --no-sort --tac --ansi)

  if [[ -n $selected ]]; then
    BUFFER=$selected
    CURSOR=${#BUFFER}
  fi
  zle reset-prompt
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

export PATH="$HOME/bin:$HOME/bin/$(hostname):$HOME/bin/$(uname -m):$PATH"
