#!/bin/bash
source "$HOME/.dotfiles/zsh/_utils.sh"

INSTALLED=`code --list-extensions`
CODE_ARGS=()
for extension in `cat $HOME/.dotfiles/vscode/extensions.txt | egrep "^[^#]+$"`; do
    CODE_ARGS+=@("--install-extension" $extension)
done

code "${CODE_ARGS[@]}"
echo "Note: Existing VSCode instances may need to be restarted!"