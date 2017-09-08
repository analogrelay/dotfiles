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
    windows $(echo -e "\uf17a")
    linux $(echo -e "\uf17c")
    apple $(echo -e "\uf179")
    folder $(echo -e "\uf07b")
    branch $(echo -e "\ue725")
    arrow $(echo -e "\ue0b0")
    prompt $(echo -e "\u203a")
    dotnet $(echo -e "\ue70c")
    clock $(echo -e "\uf017")
    terminal $(echo -e "\uf120")
    bat_empty $(echo -e "\uf244")
    bat_low $(echo -e "\uf243")
    bat_med $(echo -e "\uf242")
    bat_hi $(echo -e "\uf241")
    bat_full $(echo -e "\uf240")
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
SEGMENT_BG=bright_white

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
    next_segment black bright_cyan
    if [ "$WSL" = "1" ]; then
        write_segment "$symbols[linux] (on $symbols[windows]) $(hostname)"
    else
        write_segment "$symbols[os] $(hostname)"
    fi;
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

segment_battery() {
    local battery_status
    local percent
    local battery_symbol
    local battery_color
    local enabled

    if [[ $(uname) == "Darwin" ]]; then
        enabled="1"
        battery_status=$(pmset -g batt | sed 1d)
        percent=$(echo $battery_status | awk '{ print $3 }' | sed "s/%;$//")
    elif [ ! -z $(cat /sys/class/power_supply/battery/present) ]; then
        enabled="1"
        percent=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}' | tr -d '%')
    fi

    if [ ! -z $enabled ]; then
        if [ "$percent" -ge "95" ]; then
            battery_symbol=$symbols[bat_full]
            battery_color=bright_green
        elif [ "$percent" -ge "70" ]; then
            battery_symbol=$symbols[bat_hi]
            battery_color=green
        elif [ "$percent" -ge "45" ]; then
            battery_symbol=$symbols[bat_med]
            battery_color=bright_yellow
        elif [ "$percent" -ge "20" ]; then
            battery_symbol=$symbols[bat_low]
            battery_color=bright_red
        else
            battery_symbol=$symbols[bat_empty]
            battery_color=red
        fi

        next_segment black $battery_color
        write_segment "$battery_symbol ${percent}%%"
    fi
}

write_prompt() {
    segment_time
    segment_battery
    segment_hostname
    segment_pwd
    segment_dotnet
    segment_git

    next_segment white black

    echo "$(color_reset)"
}

export PROMPT=$'\$(write_prompt)\nzsh$symbols[prompt] '
