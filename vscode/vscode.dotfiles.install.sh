if [[ $UNAME == "Darwin" ]]; then
    link_file "$DOTFILES_ROOT/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
    link_file "$DOTFILES_ROOT/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
elif [ $WSL != "1" ]; then
    link_file "$DOTFILES_ROOT/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
    link_file "$DOTFILES_ROOT/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
fi
