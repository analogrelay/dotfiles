echo "Installing iterm2 config"

defaults write com.googlecode.iterm2 PrefsCustomFolder "$DOTFILES_ROOT/macos/iterm"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder 1