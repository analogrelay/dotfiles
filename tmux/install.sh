if [ -e ~/.tmux.conf ]; then
    rm ~/.tmux.conf
fi
ln -s ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf