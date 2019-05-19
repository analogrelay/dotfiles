
# We should be inside the DOTFILES_INSTALL context
if [ "$DOTFILES_INSTALL" != "1" ]; then
    echo "This script should be run during Dotfiles Installation only!" 1>&2
    exit 1
fi

if [ ! -d ~/.config ]; then
    mkdir ~/.config
fi

if [ ! -d ~/.config/powershell ]; then
    mkdir ~/.config/powershell
fi

# Generate a linking profile script
echo ". $DOTFILES_ROOT/ps1/profile.ps1" > ~/.config/powershell/Microsoft.PowerShell_profile.ps1