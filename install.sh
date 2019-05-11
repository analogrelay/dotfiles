#!/usr/bin/env bash

[ "$DEBUG" = "1" ] && set -x

DOTFILES_ROOT="$( cd "$(dirname "$0")" ; pwd -P )"
cd $DOTFILES_ROOT

. "./config.sh"
. "./zsh/_utils.sh"

# Generate a "Machine Name"
MACHINE_NAME=$HOSTNAME
if iswsl; then
    MACHINE_NAME="$MACHINE_NAME-wsl"
fi

# First, configure ssh if not already configured
if [ ! -e ~/.ssh/id_rsa ]; then
    echo "Creating SSH identity"
    ssh-keygen -t rsa -b 4096 -C "$MACHINE_NAME"

    cat ~/.ssh/id_rsa.pub | clipboard
    echo "SSH Public Key is now in the clipboard"
    echo "Navigate to https://github.com/settings/keys to install it."
    read -p "Press ENTER when you've configured it in GitHub ..."
fi

# Now make sure our remote is SSH
git remote set-url origin $DOTFILES_REPO

if ! type -p zsh >/dev/null; then
    echo "Installing ZSH ..."
    apt-get install zsh
fi

# If we're in ZSH, continue. Otherwise, set up ZSH
if [ "$ZSH_VERSION" = "" ]; then
    # Restart this script in ZSH
    DEBUG=$DEBUG exec zsh "$HOME/.dotfiles/install.sh"
fi

# Run install scripts
for script in ${DOTFILES_INSTALL_SCRIPTS[@]}; do
    echo "Running $script ..."
    DOTFILES_INSTALL=1 source "$script"
done

echo "Dotfiles Installation Complete!"