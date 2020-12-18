#!/usr/bin/env bash
# Install homebrew
DOTFILES_ROOT="$( cd "$(dirname $(dirname "$0"))" ; pwd -P )"
cd $DOTFILES_ROOT

source "./zsh/_utils.sh"

has_updated=false

ensure-apt() {
  if ! dpkg -l "$1" >/dev/null 2>&1; then
    apt-get-update
    apt-get install "$@"
  fi
}

if [ "$(uname)" = "Linux" ]; then
  ensure-apt build-essential curl file git
  test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
  test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

if ! type -p brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ "$CODESPACES" = "true" ]; then
  link_file "$DOTFILES_ROOT/brew/Brewfile.codespaces" ~/.Brewfile
else
  link_file "$DOTFILES_ROOT/brew/Brewfile" ~/.Brewfile
fi

echo "Updating homebrew..."
brew update

echo "Installing software..."
brew bundle --file="~/.Brewfile"