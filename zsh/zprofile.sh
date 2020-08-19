# Stuff specific to non-interactive shells. Will also be run in login shells, so stuff here shouldn't need to be in zshrc.

export GOPATH="$HOME/go"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:/Users/anurse/.dotnet/tools"
export PATH="$GOPATH/bin:$PATH"

if type rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi

export GPG_TTY="$(tty)"