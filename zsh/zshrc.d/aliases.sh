# Use nvim if available.
if [ "$USE_NVIM" != 0 ] && type nvim >/dev/null 2>&1; then
  alias vi="nvim"
  alias vim="nvim"
fi