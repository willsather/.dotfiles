# oh-my-zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# plugins
plugins=(
    git
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# override git indicator (custom theme modifications)
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%})%{$reset_color%} ▲"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})%{$reset_color%} ▲"

# environment variables
export EDITOR="nvim"
export VISUAL="$EDITOR"
export PAGER="less"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# path modifications
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.dotfiles:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# python
export PATH="$HOME/.local/bin:$PATH"

# go
export PATH="$HOME/go/bin:$PATH"

# rust
export PATH="$HOME/.cargo/bin:$PATH"

# sst
export PATH="$HOME/.sst/bin:$PATH"

# jenv setup
export PATH="$HOME/.jenv/bin:$PATH"
if command -v jenv >/dev/null 2>&1; then
    eval "$(jenv init -)"
fi

# shell aliases from nix config
alias ll="ls -l"
alias lsa="ls -la"
alias pn="pnpm"
alias kp="killport"
alias k="kubectl"

# additional useful aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias reload="source ~/.zshrc"
alias c="clear"
alias h="history"
alias j="jobs"

# development aliases
alias v="nvim"
alias vim="nvim"

# functions

# killport function from nix config
killport() {
    for port in "$@"; do
        lsof -ti:$port | xargs kill -9
    done
}

mkcd() {
    mkdir -p "$1" && cd "$1"
}

# dotfiles management
export PATH="$HOME/.dotfiles/bin:$PATH"
