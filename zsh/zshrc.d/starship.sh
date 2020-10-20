if [ "$PROMPT_USE_STARSHIP" != "no" ] && has starship; then
    eval $(starship init zsh)
fi
