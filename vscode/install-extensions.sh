#!/bin/bash
source "$HOME/.dotfiles/zsh/_utils.sh"

INSTALLED=`code --list-extensions`
for extension in `cat $HOME/.dotfiles/vscode/extensions.txt | egrep "^[^#]+$"`; do
    if echo $INSTALLED | grep -i -F "$extension" >/dev/null; then
        echo "Using $extension"
    else
        INSTALLED_ANY=1
        echo "Installing $extension"
        code --install-extension $extension
    fi
done

if [ "$INSTALLED_ANY" = "1" ]; then
    echo "Note: Existing VSCode instances may need to be restarted!"
fi