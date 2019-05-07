bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

if [ "$WSL" = "1" ]; then
    # Ctrl-Backspace
    bindkey '^_' backward-kill-word
    # Ctrl-Del
    bindkey "^[[3;5~" kill-word
fi
