# zsh configuration directory (keep all generated files organized)
export ZDOTDIR="$HOME/.dotfiles/zsh"
export ZSH_CONFIG="$ZDOTDIR/config"

# create config directories if they don't exist
[[ ! -d "$ZSH_CONFIG" ]] && mkdir -p "$ZSH_CONFIG"
[[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"

# history configuration
export HISTFILE="$ZSH_CONFIG/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000

# history options
setopt HIST_EXPIRE_DUPS_FIRST    # expire duplicate entries first when trimming history
setopt HIST_IGNORE_DUPS          # don't record an entry that was just recorded again
setopt HIST_IGNORE_ALL_DUPS      # delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS         # do not display a line previously found
setopt HIST_IGNORE_SPACE         # don't record an entry starting with a space
setopt HIST_SAVE_NO_DUPS         # don't write duplicate entries in the history file
setopt HIST_REDUCE_BLANKS        # remove superfluous blanks before recording entry
setopt HIST_VERIFY              # show command with history expansion to user before running it
setopt APPEND_HISTORY           # append to the history file, don't replace it
setopt INC_APPEND_HISTORY       # save commands are added to the history immediately
setopt SHARE_HISTORY            # share history between all sessions

# additional zsh configuration paths
export ZSH_COMPDUMP="$ZSH_CONFIG/.zcompdump"
export ZSH_CACHE_DIR="$ZSH_CONFIG/cache"

# oh-my-zsh configuration
export ZSH="$ZSH_CONFIG/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# plugins
plugins=(
    git
    zsh-autosuggestions
)

# source oh-my-zsh if it exists
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    source $ZSH/oh-my-zsh.sh
else
    echo "oh-my-zsh not found at $ZSH"
    echo "run 'dot init' to install oh-my-zsh and set up your dotfiles"
fi

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
