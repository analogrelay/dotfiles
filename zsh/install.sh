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
link_file "$DOTFILES_ROOT/zsh/zshrc.sh" "$HOME/.zshrc"
link_file "$DOTFILES_ROOT/zsh/zprofile.sh" "$HOME/.zprofile"

# Install other plugins
export ZSH_CUSTOM="$DOTFILES_ROOT/zsh/oh-my-zsh"
plugins=(https://github.com/Aloxaf/fzf-tab)
for plugin in $plugins; do
    plugin_name=$(basename $plugin)
    dest="$ZSH_CUSTOM/plugins/$plugin_name"
    if [ ! -d "$dest" ]; then
        echo "cloning $plugin ..."
        git clone $plugin $dest
    else
        echo "updating $plugin ..."
        ( cd $dest ; git pull --rebase --autostash )
    fi
done
