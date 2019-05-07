code() {
    if [[ "$WSL" = "1" ]]; then
        # VS Code COMES WITH a WSL-compatible POSIX-shell launcher!!
        command code "$@" &
    elif [[ "$(uname)" = "Darwin" ]]; then
        if [[ $# = 0 ]]
        then
            open -a "Visual Studio Code"
        else
            [[ $1 = /* ]] && F="$1" || F="$PWD/${1#./}"
            open -a "Visual Studio Code" --args "$F"
        fi
    else
        /usr/bin/code "$@"
    fi
}
