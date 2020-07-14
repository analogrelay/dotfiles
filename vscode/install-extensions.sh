#!/bin/bash
source "$HOME/.dotfiles/zsh/_utils.sh"

code_args=`cat $HOME/.dotfiles/vscode/extensions.txt | egrep "^[^#]+$" | awk '{ ORS=" "; print "--install-extension " $0 }'`
code $code_args

if pgrep code >/dev/null; then
    echo "WARNING: Existing VSCode instances may need to be restarted!" 1>&2
fi
