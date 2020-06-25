export PATH="$HOME/.dotfiles/bin:$PATH"

abspath() {
    local input="$1"

    # Special case '.' and '..' because the normal process
    # *works* but isn't pretty :)
    case "$input" in
        ".")
            pwd
            ;;
        "..")
            dirname "$(pwd)"
            ;;
        *)
            local parent="$(dirname "$input")"
            local leaf="$(basename "$input")"
            parent="$(cd $parent; pwd)"
            if [ "$parent" = "/" ]; then
                echo "/$leaf"
            else
                echo "$parent/$leaf"
            fi
            ;;
    esac
}

enpathen() {
    local newPaths=()
    while [[ "$#" -gt 0 ]]; do
        key="$1"
        shift

        case $key in
            -a|--append)
                local append=1
                ;;
            -n|--dry-run)
                local dry_run=1
                ;;
            *)
                # Resolve the path
                newPaths+=("$(abspath $key)")
        esac
    done

    newPath="${(j.:.)newPaths}"
    if [ -z "$append" ]; then
        # Not append => prepend
        echo "Prepending: '$newPath' to PATH"
        if [ -z "$dry_run" ]; then
            export PATH="$newPath:$PATH"
        fi
    else
        echo "Appending: '$newPath' to PATH"
        if [ -z "$dry_run" ]; then
            export PATH="$PATH:$newPath"
        fi
    fi
}