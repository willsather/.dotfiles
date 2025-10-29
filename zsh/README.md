# Zsh Configuration

This directory contains the zsh configuration for the dotfiles setup.

## Structure

- `.zshrc` - Main zsh configuration file (symlinked to `~/.zshrc`)
- `config/` - Directory for all zsh-generated files (gitignored)
  - `.zsh_history` - Command history
  - `.zcompdump` - Completion cache
  - `.oh-my-zsh/` - Oh My Zsh installation
  - `cache/` - Various zsh cache files

## Features

- All zsh-generated files are contained within the `config/` directory
- Automatic installation of Oh My Zsh and zsh-autosuggestions plugin
- Clean home directory without scattered zsh files
- Comprehensive history configuration
- Custom aliases and functions

## Setup

The configuration automatically:
1. Creates the `config/` directory if it doesn't exist
2. Redirects all zsh files to the config directory

Oh My Zsh and plugins are installed by the `dot init` command to the proper config location.

## Environment Variables

- `ZDOTDIR` - Points to this zsh directory
- `ZSH_CONFIG` - Points to the config subdirectory
- `HISTFILE` - History file location within config
- `ZSH_COMPDUMP` - Completion dump location within config
- `ZSH_CACHE_DIR` - Cache directory within config