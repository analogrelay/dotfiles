alias reload!='. ~/.zshrc'

if [[ $(uname) == "Darwin" ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi
