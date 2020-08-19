# This script can't assume we're in ZSH because it will be run by whatever script is preinstalled on the machine.

# We should be inside the DOTFILES_INSTALL context
if [ "$DOTFILES_INSTALL" != "1" ]; then
    echo "This script should be run during Dotfiles Installation only!" 1>&2
    exit 1
fi

# Install oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
    trace_out "oh-my-zsh already installed"
fi

# Symlink zshrc
if [ -e ~/.zshrc ]; then
    rm ~/.zshrc
fi
link_file ~/.dotfiles/zsh/zshrc.sh ~/.zshrc

if [ -e ~/.zprofile ]; then
    rm ~/.zprofile
fi
link_file ~/.dotfiles/zsh/zprofile.sh ~/.zprofile