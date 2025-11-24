# Dotfiles

## Future Install Script

1. Install Brew
2. Install Xcode Tools
3. Clone `.dotfiles` repository
4. Brew Bundle
5. Build and run `dot`

A simple dotfiles management system for macOS using Homebrew Bundle and GNU Stow.

## Installation

```bash
git clone https://github.com/willsather/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

./dot init
```

That's it! Restart your terminal and the `dot` command will be available globally.

## What you get

- **Package management** via Brewfile (brew bundle)
- **Clean symlinks** via GNU Stow (no dotfile clutter in ~)
- **Modern CLI tools** (ripgrep, bat, exa, etc.)
- **ZSH + Oh My Zsh** with useful aliases and plugins
- **Git configuration** with helpful aliases
- **macOS system defaults** for optimal experience

## Commands

```bash
dot add git                     # add cli package
dot add docker cask             # add gui app
dot add "Xcode" mas 497799835   # add mac app store app
dot remove package-name         # remove package
dot remove package-name         # remove package
dot list                        # show all packages
dot cleanup                     # remove packages not in Brewfile
dot dump                        # generate Brewfile from current system
```

## Structure

```
.dotfiles/
├── dot                       # main command
├── Brewfile                  # package definitions
├── home/                     # dotfiles to be symlinked to home directory
│   ├── .zshrc                # shell configuration
│   ├── .claude/              # Claude AI configuration
│   └── .config/              # XDG config directory
│       ├── git/              # git configuration
│       ├── nvim/             # Neovim configuration
│       └── zed/              # Zed editor configuration
├── macos/                    # macOS-specific configurations
│   └── defaults.sh           # system preferences
├── utils/                    # utility scripts
│   └── log.sh                # logging utilities
└── .zsh/                     # ZSH runtime data
    └── .oh-my-zsh/           # Oh My Zsh installation
```
