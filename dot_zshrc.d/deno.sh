if [ ! -d "$HOME/.deno" ]; then
    return
fi

if [ -d "$HOME/.deno/bin" ]; then
    export DENO_INSTALL="$HOME/.deno"
    export PATH="$HOME/.deno/bin:$PATH"
fi