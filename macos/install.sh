# Install Homebrew if needed
if ! has brew; then
    echo "Installing Homebrew"
else
    trace_out "Homebrew installed"
fi

# The base set of packages depended upon by dotfiles
BASE_PACKAGES=(
    "jq"
)

BASE_CASKS=(
    "visual-studio-code"
    "iterm2"
)

_brew_install_pkgs() {
    local INSTALL_SET=()
    for package in $BASE_PACKAGES; do
        if ! brew list $package >/dev/null 2>/dev/null; then
            INSTALL_SET+=($package)
        else
            trace_out "Package already installed $package"
        fi
    done

    if [ ! -z $INSTALL_SET ]; then
        echo "Installing package $INSTALL_SET ..."
        brew install "${INSTALL_SET[@]}"
    fi
}

_brew_install_casks() {
    local INSTALL_SET=()
    for package in $BASE_CASKS; do
        if ! brew cask list $package >/dev/null 2>/dev/null; then
            INSTALL_SET+=($package)
        else
            trace_out "Cask already installed $package"
        fi
    done

    if [ ! -z $INSTALL_SET ]; then
        echo "Installing cask $INSTALL_SET ..."
        brew cask install "${INSTALL_SET[@]}"
    fi
}

_brew_install_pkgs
_brew_install_casks

MACOS_INSTALL_SCRIPTS=( "./macos/iterm/install.sh" )

for script in $MACOS_INSTALL_SCRIPTS; do
    echo "Running $script ..."
    DOTFILES_INSTALL=1 source "$script"
done