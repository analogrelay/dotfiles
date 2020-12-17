#!/usr/bin/env bash
# Install homebrew
DOTFILES_ROOT="$( cd "$(dirname $(dirname "$0"))" ; pwd -P )"
cd $DOTFILES_ROOT

source "./zsh/_utils.sh"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

link_file ~/.dotfiles/brew/Brewfile ~/.Brewfile