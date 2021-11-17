# Stuff specific to non-interactive shells. Will also be run in login shells, so stuff here shouldn't need to be in zshrc.

export GOPATH="$HOME/go"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"

if type rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi

export GPG_TTY="$(tty)"

THEARCH=$(arch)
export HOMEBREW_PREFIX=""
export HOMEBREW_SHELLENV_PREFIX=""
if [[ x"$THEARCH" == x"i386" ]]; then
	eval $(/usr/local/bin/brew shellenv)
else
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi