# Bind ESC+d to backward-kill-word when in iTerm
if [ ! -z $ITERM_PROFILE ]; then
    bindkey "^[d" backward-kill-word
fi