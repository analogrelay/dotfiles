# We should be inside the DOTFILES_INSTALL context
if [ "$DOTFILES_INSTALL" != "1" ]; then
    echo "This script should be run during Dotfiles Installation only!" 1>&2
    exit 1
fi

if [ -e ~/.vimrc ] || [ -L ~/.vimrc ]; then
    trace_out "Removing existing vimrc"
    rm ~/.vimrc
fi

link_file "$DOTFILES_ROOT/vim/vimrc.vim" ~/.vimrc
link_file "$DOTFILES_ROOT/vim" ~/.vim