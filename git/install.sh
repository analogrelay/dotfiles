# This script can't assume we're in ZSH because it will be run by whatever script is preinstalled on the machine.

# We should be inside the DOTFILES_INSTALL context
if [ "$DOTFILES_INSTALL" != "1" ]; then
    echo "This script should be run during Dotfiles Installation only!" 1>&2
    exit 1
fi

echo "Configuring Git..."

read "? - What is your Git author name? " AUTHOR_NAME
read "? - What is your Git author email? " AUTHOR_EMAIL

if [ -f ~/.gitconfig ]; then
    if confirm "A git config file already exists in '~/.gitconfig'. Remove it?"; then
        rm ~/.gitconfig
    fi
fi

# Copy the git config in
cp ~/.dotfiles/git/.gitconfig ~/.gitconfig

echo "[user]" >> ~/.gitconfig
echo "    name = $AUTHOR_NAME" >> ~/.gitconfig
echo "    email = $AUTHOR_EMAIL" >> ~/.gitconfig
