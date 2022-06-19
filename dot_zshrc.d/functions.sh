# Mark all files with no extension in there as autoload
FUNCS_TO_AUTOLOAD=("${(@f)$(find "$HOME/.zshrc.d/functions" -type f \! -name "*.*")}")
for func in $FUNCS_TO_AUTOLOAD; do
    autoload $func
done