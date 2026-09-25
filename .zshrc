# -------------------------------
# Custom completions (must be before oh-my-zsh / compinit)
# Regenerate with: uv generate-shell-completion zsh > ~/.zfunc/_uv && cp ~/.zfunc/_uv ~/.zfunc/_uvx && mise completion zsh > ~/.zfunc/_mise && opencode completion zsh > ~/.zfunc/_opencode && rustup completions zsh > ~/.zfunc/_rustup && rustup completions zsh cargo > ~/.zfunc/_cargo
# -------------------------------
fpath=(~/.zfunc $fpath)

# Oh My Zsh setup
# -------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
fpath=("$HOME/.zsh/completions" $fpath)

plugins=(
    git
    z
    azure
    kubectl
    helm
    fzf-tab
    zsh-autosuggestions
    zsh-syntax-highlighting
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
# mise setup (net-new tools only: fd, prettier, lua-language-server)
# -------------------------------
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
[[ -x "$HOME/.local/bin/mise" ]] && eval "$("$HOME/.local/bin/mise" activate zsh)"

# -------------------------------
# PATH (typeset -U deduplicates)
# -------------------------------
typeset -U path PATH
path=("${(@)path:#*;*}")
path=(
    "$HOME/.opencode/bin"
    "$HOME/bin"
    "$HOME/bin/$(hostname)"
    "$HOME/bin/$(uname -m)"
    "$HOME/.cargo/bin"
    $path
)

# -------------------------------
# Completion tuning (compinit is run by oh-my-zsh)
# -------------------------------
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

zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' continuous-trigger 'tab'
zstyle ':fzf-tab:*' accept-line tab

# -------------------------------
# Environment variables & aliases
# -------------------------------
export LANG=en_US.UTF-8
export EDITOR=nvim
alias cat=bat
alias ls=eza
alias ll="eza -lh --time-style=long-iso -smodified -r"
alias pcat="bat --plain --pager="
alias vim="nvim"
alias vi="nvim"
alias k="kubectl"

compdef k=kubectl

# Cache generated completions so large scripts are not rebuilt on every shell startup.
_load_completion() {
    local name=$1
    shift
    local completion_file="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions/_${name}"

    if [[ ! -s "$completion_file" ]] && command -v "$name" >/dev/null 2>&1; then
        mkdir -p "${completion_file:h}"
        "$@" >| "$completion_file" 2>/dev/null || rm -f "$completion_file"
    fi

    [[ -s "$completion_file" ]] && source "$completion_file"
}

_load_completion uv uv generate-shell-completion zsh
_load_completion uvx uvx --generate-shell-completion zsh
_load_completion ruff ruff generate-shell-completion zsh
_load_completion gh gh completion --shell zsh
_load_completion opencode opencode completion zsh
unfunction _load_completion

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

    echo "${color} ${branch}${extra}%f"
}

PROMPT='%F{cyan}${PWD}%f $(git_prompt_info) %F{magenta}%f '

# -------------------------------
# vi mode & keybindings
# -------------------------------
bindkey -v
bindkey -M viins 'kj' vi-cmd-mode
bindkey -M visual 'kj' vi-cmd-mode
bindkey -M viins $'\ev' edit-command-line
bindkey -M vicmd $'\ev' edit-command-line

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

# Apply the cached pywal palette to new terminals.
[[ -f "$HOME/.cache/wal/sequences" ]] && (command cat "$HOME/.cache/wal/sequences" &)

# Allow terminal nvim <C-s> (treesel): disable XON/XOFF flow control on interactive TTYs
[[ -t 0 ]] && stty -ixon 2>/dev/null || true

# bun
export BUN_INSTALL="$HOME/.bun"
path=("${(@)path:#$BUN_INSTALL/bin}")
[[ -d "$BUN_INSTALL/bin" ]] && path=("$BUN_INSTALL/bin" $path)
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
