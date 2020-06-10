# We should be inside the DOTFILES_INSTALL context
if [ "$DOTFILES_INSTALL" != "1" ]; then
    echo "This script should be run during Dotfiles Installation only!" 1>&2
    exit 1
fi

SETTINGS_ROOT=
if ismacos; then
    SETTINGS_ROOT="$HOME/Library/Application Support/Code/User"
else
    SETTINGS_ROOT="$HOME/.config/Code/User"
fi

# Link the files in to place
link_file ~/.dotfiles/vscode/settings.json "$SETTINGS_ROOT/settings.json"
link_file ~/.dotfiles/vscode/keybindings.json "$SETTINGS_ROOT/keybindings.json"

if ! has code; then
    echo "Skipping extension install. VS Code is not yet installed."
else
    INSTALLED=`code --list-extensions`
    for extension in `cat ./vscode/extensions.txt | egrep "^[^#]+$"`; do
        if echo $INSTALLED | grep -i -F "$extension" >/dev/null; then
            trace_out "Skipping installed extension $extension"
        else
            INSTALLED_ANY=1
            echo "Installing VS Code extension $extension"
            code --install-extension $extension
        fi
    done

    if [ "$INSTALLED_ANY" = "1" ]; then
        echo "Note: Existing VSCode instances may need to be restarted!"
    fi
fi