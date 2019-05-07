# This script can't assume we're in ZSH because it will be run by whatever script is preinstalled on the machine.

# We should be inside the DOTFILES_INSTALL context
if [ "$DOTFILES_INSTALL" != "1" ]; then
    echo "This script should be run during Dotfiles Installation only!" 1>&2
    exit 1
fi

# We're guaranteed to be running in the dotfiles repo root
. "./zsh/_utils.sh"

# Install ZSH if not already present
if ! has zsh; then
    echo "Installing ZSH ..."
    installpkg zsh
fi

# Install oh-my-zsh