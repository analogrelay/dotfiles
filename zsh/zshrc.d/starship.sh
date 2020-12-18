if [ "$PROMPT_USE_STARSHIP" != "no" ] && type -p starship >/dev/null 2>&1; then
    eval $(starship init zsh)
fi
