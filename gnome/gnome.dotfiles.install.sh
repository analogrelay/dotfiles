for file in $(find "$DOTFILES_ROOT/gnome" -name *.dconf); do
    info "Installing dconf setting $file"
    dconf load / < $file
done
