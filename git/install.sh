# This script can't assume we're in ZSH because it will be run by whatever script is preinstalled on the machine.

# We should be inside the DOTFILES_INSTALL context
if [ "$DOTFILES_INSTALL" != "1" ]; then
    echo "This script should be run during Dotfiles Installation only!" 1>&2
    exit 1
fi

echo "Configuring Git..."

# Link gitconfig
link_file ~/.dotfiles/git/gitconfig ~/.gitconfig

# Check if we need to generate a new author config

GITHUB_USER=$(git config github.user)
if [ -z "$GITHUB_USER" ]; then
    read "? - What is your GitHub user name? " GITHUB_USER
    git config --file ~/.gitlocal github.user $GITHUB_USER
fi

AUTHOR_NAME=$(git config user.name)
if [ -z "$AUTHOR_NAME" ]; then
    read "? - What is your Git author name? " AUTHOR_NAME
    git config --file ~/.gitlocal user.name $AUTHOR_NAME
fi

AUTHOR_EMAIL=$(git config user.email)
if [ -z "$AUTHOR_EMAIL" ]; then
    read "? - What is your Git author email? " AUTHOR_EMAIL
    git config --file ~/.gitlocal user.email $AUTHOR_EMAIL
fi

# Configure credential helper per-OS
EXPECTED_HELPER=
if [ "$(uname)" = "Darwin" ]; then
    EXPECTED_HELPER=credential-osxkeychain
fi

CURRENT_HELPER=$(git config credential.helper)
if [ "$CURRENT_HELPER" != "$EXPECTED_HELPER" ]; then
    echo "Updating git credential.helper to '$EXPECTED_HELPER'"
    git config --file ~/.gitlocal credential.helper "$EXPECTED_HELPER"
fi