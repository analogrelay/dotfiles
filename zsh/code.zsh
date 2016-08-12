#!/bin/sh

code() {
    if [ $WSL = "1" ]; then
        if ! type -p wstart >/dev/null 2>/dev/null; then
            echo "Can't find 'wstart'. Install cbwin to call back to Windows apps." 1>&2
            return 1
        fi
        wstart "C:\Progra~2\MIFA7F~1\Code.exe" "$@"
    elif [ $(uname) = "Darwin" ]; then
        if [[ $# = 0 ]]
        then
            open -a "Visual Studio Code"
        else
            [[ $1 = /* ]] && F="$1" || F="$PWD/${1#./}"
            open -a "Visual Studio Code" --args "$F"
        fi
    else
        echo "Not yet implemented!" 1>&2
        return 1
    fi
}
