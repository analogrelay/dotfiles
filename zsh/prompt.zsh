# Make our own color tables
typeset -A fg bg color

color=(
    0 black
    1 red
    2 green
    3 yellow
    4 blue
    5 magenta
    6 cyan
    7 white)

# reverse map
local k
for k in ${(k)color}; do color[${color[$k]}]=$k; done

# Build the fg/bg tables
local name
for k in {0..7}; do
    name=$color[$k]
    fg[$name]=$(( $k + 30 ))
    fg[bright_$name]=$(( $k + 90 ))
    bg[$name]=$(( $k + 40 ))
    bg[bright_$name]=$(( $k + 100 ))
done

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

if [[ "$(uname)" == "Darwin" ]]; then
    symbols[os]=$symbols[apple]
else
    symbols[os]=$symbols[linux]
fi

color() {
    FG_COLOR=
    if [ ! -z $1 ]; then
        FG_COLOR="\e[$fg[$1]m"
    fi
    BG_COLOR=
    if [ ! -z $2 ]; then
        BG_COLOR="\e[$bg[$2]m"
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
    next_segment black bright_yellow
    write_segment "$symbols[folder] %~"
}

segment_hostname() {
    next_segment black cyan
    write_segment "$symbols[os] $(hostname)"
}

segment_dotnet() {
    if type dotnet >/dev/null 2>/dev/null; then
        next_segment bright_white blue
        write_segment "$symbols[dotnet] $(dotnet --version)"
    fi
}

segment_git() {
    # Do we has a git?
    if ! type git >/dev/null 2>/dev/null; then
        return
    fi

    # Is this a git repo?
    if ! git status -s &>/dev/null; then
        return
    fi

    local branch=$(git rev-parse --abbrev-ref HEAD)

    if [[ $(git status --porcelain) == "" ]]; then
        next_segment black green
    else
        next_segment black bright_red
    fi
    write_segment "$symbols[branch] $branch"
}

write_prompt() {
    segment_time
    segment_hostname
    segment_pwd
    segment_dotnet
    segment_git

    next_segment white black

    echo "$(color_reset)"
    echo "$symbols[prompt] "
}

export PROMPT="$(write_prompt)"
