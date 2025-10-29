# Dotfiles

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
├── zsh/.zshrc                # shell config (symlinks to ~/.zshrc)
├── git/.gitconfig            # git config (symlinks to ~/.gitconfig)
└── macos/defaults.sh         # system preferences
```
