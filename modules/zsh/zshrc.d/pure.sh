# Configure zstyle prompts
zstyle ":prompt:pure:path" "color" "147"
zstyle ":prompt:pure:git:branch" "color" "048"
zstyle ":prompt:pure:git:action" "color" "048"
zstyle ":prompt:pure:git:arrow" "color" "048"
zstyle ":prompt:pure:prompt:success" "color" "155"

if [ "$PROMPT_USE_PURE" != "no" ] && has starship; then
	fpath+=$HOME/.dotfiles/pure/pure
	autoload -U promptinit; promptinit
	prompt pure
fi
