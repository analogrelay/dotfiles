# We should be inside the DOTFILES_INSTALL context
if [ "$DOTFILES_INSTALL" != "1" ]; then
    echo "This script should be run during Dotfiles Installation only!" 1>&2
    exit 1
fi

if [ -e ~/.tmux.conf ] || [ -L ~/.tmux.conf ]; then
    trace_out "Removing existing tmux.conf symlink"
    rm ~/.tmux.conf
fi

if [ -e ~/.tmux.conf.local ] || [ -L ~/.tmux.conf.local ]; then
    trace_out "Removing existing tmux.conf.local symlink"
    rm ~/.tmux.conf.local
fi

link_file ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf
link_file ~/.dotfiles/tmux/tmux.conf.local ~/.tmux.conf.local
