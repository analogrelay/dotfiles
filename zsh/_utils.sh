# Should be dot-sourced!

has() {
    type -p "$1" >/dev/null
}

islinux() {
    uname | grep "Linux" >/dev/null
}

isdistro() {
    cat /etc/os-release | grep "ID=$1" >/dev/null
}

isdebian() {
    islinux && isdistro "debian"
}

iswsl() {
    uname -r | grep "Microsoft" >/dev/null
}

clipboard() {
    read content
    if iswsl; then
        echo $content | clip.exe
    else
        echo "Unsupported OS!" 1>&2
        exit 1
    fi
}

updatepkg() {
    if isdebian; then
        sudo apt-get update
    else
        echo "Unsupported OS!" 1>&2
    fi
}

installpkg() {
    if isdebian; then
        sudo apt-get install -y "$@"
    else
        echo "Unsupported OS!" 1>&2
    fi
}

confirm() {
    read -q "?$1 [y/N]"
}