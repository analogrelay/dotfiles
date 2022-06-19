if ! type antigen >/dev/null 2>&1; then
    return;
fi

antigen use oh-my-zsh

antigen bundle git
antigen bundle Aloxaf/fzf-tab

# Start an ssh-agent if there isn't one already
if [ -z "$SSH_AUTH_SOCK" ]; then
    antigen bundle ssh-agent
fi

antigen bundle zsh-users/zsh-completions

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle softmoth/zsh-vim-mode

antigen apply