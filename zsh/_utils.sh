# Should be dot-sourced!

# Reset
ANSI_RESET=$(printf '\033[0m')       # Text Reset

# Regular Colors
ANSI_FG_BLACK=$(printf '\033[0;30m')        # Black
ANSI_FG_RED=$(printf '\033[0;31m')          # Red
ANSI_FG_GREEN=$(printf '\033[0;32m')        # Green
ANSI_FG_YELLOW=$(printf '\033[0;33m')       # Yellow
ANSI_FG_BLUE=$(printf '\033[0;34m')         # Blue
ANSI_FG_PURPLE=$(printf '\033[0;35m')       # Purple
ANSI_FG_CYAN=$(printf '\033[0;36m')         # Cyan
ANSI_FG_WHITE=$(printf '\033[0;37m')        # White

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

ismacos() {
    uname | grep "Darwin" >/dev/null
}

clipboard() {
    read content
    if iswsl; then
        echo $content | clip.exe
    elif ismacos; then
        echo $content | pbcopy
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
    read -q "?$1 [y/N] "
    local read_exit=$?
    echo
    return $read_exit
}

trace_out() {
    if [ "$DOTFILES_TRACE" = "1" ]; then
        echo "${ANSI_FG_PURPLE}trace:$ANSI_RESET $1"
    fi
}

warn() {
    echo "${ANSI_FG_YELLOW}warn :$ANSI_RESET $1"
}

link_file() {
    local SRC=$1
    local TGT=$2
    if [ -e $TGT ]; then
        # Back up the file
        local TMP=$(mktemp -d -t "dotfiles-backup-$(basename $TGT)")
        warn "Replacing $TGT. Backed up original to $TMP"
        cp $TGT $TMP
        rm $TGT
    fi  
    ln -s $SRC $TGT
}