goto() {
    target=$1

    if [ -z "$1" ]; then
        echo "Usage: goto <TARGET>" 1>&2
        echo "" 1>&2
        echo "Targets:" 1>&2
        echo "  * <OWNER>/<REPO> - Go to cloned repo" 1>&2
        return 1
    fi

    if [[ $target =~ "^([a-zA-Z0-9\-_]+)/([a-zA-Z0-9\-_]+)$" ]]; then
        owner=$match[1]
        repo=$match[2]
        dest=~/code/$owner/$repo
        if [ -d $dest ]; then
            cd $dest
        elif confirm "$owner/$repo has not been cloned. Clone it?"; then
            clone "$owner/$repo"
        fi
    fi
}