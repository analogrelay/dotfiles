AZ_COMPLETION_PATH="$HOME/.dotfiles/local/az.completion"

if type -p az >/dev/null 2>&1; then
    if [ ! -e "$AZ_COMPLETION_PATH" ]; then
        if type -p curl >/dev/null 2>&1; then
            echo "Downloading azure-cli completions..."
            curl -sSL -o "$AZ_COMPLETION_PATH" https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion
        fi
    fi

    if [ -e "$AZ_COMPLETION_PATH" ]; then
        chmod a+x "$AZ_COMPLETION_PATH"
        autoload bashcompinit && bashcompinit
        source "$AZ_COMPLETION_PATH"
    fi
fi