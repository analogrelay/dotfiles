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
AUTHOR_NAME=$(git config user.name)
AUTHOR_EMAIL=$(git config user.email)

if [ -z "$AUTHOR_NAME" ]; then
    read "? - What is your Git author name? " AUTHOR_NAME
fi

if [ -z "$AUTHOR_EMAIL" ]; then
    read "? - What is your Git author email? " AUTHOR_EMAIL
fi

trace_out "Installing gitauthor file"
echo "[user]" > ~/.gitauthor
echo "    name = $AUTHOR_NAME" >> ~/.gitauthor
echo "    email = $AUTHOR_EMAIL" >> ~/.gitauthor