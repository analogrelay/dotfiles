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

# Color table
typeset -A vc_color_base
vc_color_base=([black]=0 [red]=1 [green]=2 [yellow]=3 [blue]=4 [magenta]=5 [cyan]=6 [white]=7)

typeset -A vc_color
for color_base in ${(k)vc_color_base}; do
    vc_color[$color_base]=$(($vc_color_base[$color_base] + 30))
    vc_color[bright_$color_base]=$(($vc_color_base[$color_base] + 90))
done

# Don't need the color base variable anymore
unset vc_color_base

typeset -A vc_fg
typeset -A vc_bg
for color_name in ${(k)vc_color}; do
    vc_fg[$color_name]=$(echo "\e[0;$vc_color[$color_name]m")
    vc_bg[$color_name]=$(echo "\e[0;$(($vc_color[$color_name] + 10))m")
done