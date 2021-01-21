#!/usr/bin/env zsh
if [ -z "$ZSH_VERSION" ]; then
  echo "stage 2 must be run from zsh!" 1>&2
  exit 1
fi

[ "$DEBUG" = "1" ] && set -x

DOTFILES_ROOT="$( cd "$(dirname $(dirname "$0"))" ; pwd -P )"
cd $DOTFILES_ROOT

source "$DOTFILES_ROOT/zsh/_utils.sh"
source "$DOTFILES_ROOT/config.sh"

# Skip SSH config if we're on Codespaces
if [ "$CODESPACES" != "true" ]; then
    # First, configure ssh if not already configured
    if [ ! -e ~/.ssh/id_rsa ]; then
        echo "Creating SSH identity"
        ssh-keygen -t rsa -b 4096 -C "$MACHINE_NAME"

        cat ~/.ssh/id_rsa.pub | clipboard
        echo "SSH Public Key is now in the clipboard"
        echo "Navigate to https://github.com/settings/keys to install it."
        read -p "Press ENTER when you've configured it in GitHub ..."
    fi
fi

# Now make sure our remote is SSH
git remote set-url origin $DOTFILES_REPO

FORCE=1 "$DOTFILES_ROOT/script/install-links.sh"

# Run install scripts
for script in ${DOTFILES_INSTALL_SCRIPTS[@]}; do
    echo -e "\e[35m=== Running $script ... ===\e[0m"
    DOTFILES_INSTALL=1 source "$script"
done

echo "Dotfiles Installation Complete!"