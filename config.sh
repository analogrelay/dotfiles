DOTFILES_REPO="git@github.com:anurse/dotfiles.git"

# Install scripts to be run (relative to repo root)
DOTFILES_INSTALL_SCRIPTS=(
    "./zsh/install.sh"
    "./git/install.sh"
    "./gpg/install.sh"
    "./ps1/install.sh"
    "./tmux/install.sh"
    "./fonts/install.sh"
    "./vscode/install.sh"
    "./ruby/install.sh"
)

if [ "$(uname)" = "Darwin" ]; then
    DOTFILES_INSTALL_SCRIPTS=( "./macos/install.sh" $DOTFILES_INSTALL_SCRIPTS[@] "./macos/iterm/install.sh" )
fi