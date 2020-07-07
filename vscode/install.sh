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
    "$HOME/.dotfiles/vscode/install-extensions.sh"
fi