autoload colors && colors

typeset -A symbols
symbols=(
    windows "\uf17a"
    linux "\uf17c"
    apple "\uf179"
    folder "\uf07b"
    branch "\ue725"
    arrow "\ue0b0"
    prompt "\u203a"
    dotnet "\ue70c"
    clock "\uf017"
)

if [[ "$UNAME" == "Darwin" ]]; then
    symbols[os]=$symbols[apple]
else
    symbols[os]=$symbols[linux]
fi

color() {
    FG_COLOR=
    if [ ! -z $1 ]; then
        FG_COLOR="$fg[$1]"
    fi
    BG_COLOR=
    if [ ! -z $2 ]; then
        BG_COLOR="$bg[$2]"
    fi
    echo -e "${FG_COLOR}${BG_COLOR}"
}

color_reset() {
    echo -e "\e[0m"
}

write_colored() {
    local MESSAGE=$1
    local FG=$2
    local BG=$3

    echo "$(color $FG $BG)${MESSAGE}$(color_reset)"
}

SEGMENT_FG=black
SEGMENT_BG=white

write_segment() {
    local CONTENT=$1
    echo -n "$(color $SEGMENT_FG $SEGMENT_BG) ${CONTENT} $(color_reset)"
}

next_segment() {
    local NEXT_FG=$1
    local NEXT_BG=$2

    echo -n "$(color $SEGMENT_BG $NEXT_BG)$symbols[arrow]$(color_reset)"

    SEGMENT_FG=$NEXT_FG
    SEGMENT_BG=$NEXT_BG
}

segment_time() {
    write_segment "$symbols[clock] $(date +"%H:%M")"
}

segment_pwd() {
    next_segment black yellow
    write_segment "$symbols[folder] %~"
}

segment_hostname() {
    next_segment black cyan
    write_segment "$symbols[os] $(hostname)"
}

segment_dotnet() {
    if type dotnet >/dev/null 2>/dev/null; then
        next_segment white blue
        write_segment "$symbols[dotnet] $(dotnet --version)"
    fi
}

write_prompt() {
    segment_time
    segment_hostname
    segment_pwd
    segment_dotnet

    echo "$(color_reset)"
    echo "$symbols[prompt] "
}

export PROMPT="$(write_prompt)"
