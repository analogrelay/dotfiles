# We should be inside the DOTFILES_INSTALL context
if [ "$DOTFILES_INSTALL" != "1" ]; then
    echo "This script should be run during Dotfiles Installation only!" 1>&2
    exit 1
fi

SETTINGS_ROOT=
if [ "$(uname)" = "Darwin" ]; then
    SETTINGS_ROOT="$HOME/Library/Application Support/Code/User"
else
    SETTINGS_ROOT="$HOME/.config/Code/User"
fi

# Link the user dir in place
link_file "$HOME/.dotfiles/vscode/user" "$SETTINGS_ROOT"

if ! type -p code >/dev/null 2>&1; then
    echo "Skipping extension install. VS Code is not yet installed."
else
    "$HOME/.dotfiles/vscode/install-extensions.sh"
fi
