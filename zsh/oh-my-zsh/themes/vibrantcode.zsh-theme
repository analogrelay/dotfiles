# vim:ft=zsh ts=2 sw=2 sts=2


# VibrantCode, based on agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [NerdFont-patched font](https://github.com/ryanoasis/nerd-fonts).
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

# Icons
typeset -A vc_icons
vc_icons[dotnet]="\ue77f"
vc_icons[rust]="\ue7a8"
vc_icons[windows]="\ue70f"
vc_icons[linux]="\ue712"
vc_icons[mac]="\ue711"
vc_icons[ruby]="\ue605"

if [ "$(uname)" = "Linux" ]; then
  os_icon="$vc_icons[linux]"
  if uname -r | grep Microsoft >/dev/null; then
    os_icon="$os_icon (on $vc_icons[windows])"
  fi
elif [ "$(uname)" = "Darwin" ]; then
  os_icon="$vc_icons[mac]"
fi

# Color table
typeset -A vc_color_base
vc_color_base[black]=0
vc_color_base[red]=1
vc_color_base[green]=2
vc_color_base[yellow]=3
vc_color_base[blue]=4
vc_color_base[magenta]=5
vc_color_base[cyan]=6
vc_color_base[white]=7
vc_color_base[default]=9

typeset -A vc_color
for color_base in ${(k)vc_color_base}; do
  vc_color[$color_base]=$(($vc_color_base[$color_base] + 30))

  if [ "$color_name" != "default" ]; then
    vc_color[bright_$color_base]=$(($vc_color_base[$color_base] + 90))
  fi
done

# Don't need the color base variable anymore
unset vc_color_base

typeset -A vc_fg
typeset -A vc_bg
for color_name in ${(k)vc_color}; do
  vc_fg[$color_name]=$(echo "\e[$vc_color[$color_name]m")
  vc_bg[$color_name]=$(echo "\e[$(($vc_color[$color_name] + 10))m")
done

ansi_reset=$(echo "\e[0m")

CURRENT_BG='NONE'

case ${SOLARIZED_THEME:-dark} in
  light) CURRENT_FG='white';;
  *)     CURRENT_FG='black';;
esac

# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.
  # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
  SEGMENT_SEPARATOR=$'\ue0b0'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bgc fgc
  [[ -n $1 ]] && bgc="$1" || bgc="default"
  [[ -n $2 ]] && fgc="$2" || fgc="default"

  if [[ $CURRENT_BG == 'NONE' ]]; then
    echo -n "$vc_bg[$bgc]$vc_fg[$fgc]"
  elif [[ $1 == $CURRENT_BG ]]; then
    echo -n "$vc_bg[$bgc]$vc_fg[$fgc] "
  else
    echo -n " $vc_fg[$CURRENT_BG]$vc_bg[$bgc]$SEGMENT_SEPARATOR $vc_fg[$fgc]"
  fi
  CURRENT_BG=$bgc
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " $vc_bg[default]$vc_fg[$CURRENT_BG]$SEGMENT_SEPARATOR"
  else
    echo -n "$vc_bg[default]"
  fi
  echo -n "$vc_fg[default]"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black white "%(!.$vc_fg[yellow].)%n@%m $os_icon"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment bright_yellow black
    else
      prompt_segment bright_green $CURRENT_FG
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '●'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment cyan white '%~'
}

prompt_rust() {
  if type -p rustc >/dev/null; then
    if rustc --version | grep nightly >/dev/null; then
      rustver=$(rustc --version | awk '{print $2, $3, $4}')
    else
      rustver=$(rustc --version | awk '{print $2}')
    fi
    prompt_segment red white "$vc_icons[rust] $rustver"
  fi
}

prompt_dotnet() {
  if type -p dotnet >/dev/null; then
    prompt_segment blue white "$vc_icons[dotnet] $(dotnet --version)"
  fi
}

prompt_rbenv() {
  if type -p rbenv >/dev/null; then
    prompt_segment red white "$vc_icons[ruby] $(rbenv version-name)"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local -a symbols

  if [[ $RETVAL -ne 0 ]]; then
    symbols+="$vc_fg[red]✘"
  else 
    symbols+="$vc_fg[bright_green]✓"
  fi
  [[ $UID -eq 0 ]] && symbols+="$vc_fg[yellow]⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="$vc_fg[cyan]⚙"

  [[ -n "$symbols" ]] && prompt_segment black white "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  prompt_dotnet
  prompt_rbenv
  prompt_rust
  prompt_dir
  prompt_git
  prompt_end
}

final_prompt() {
  echo -n "$vc_fg[bright_blue]zsh \$$vc_fg[default]"
}

PROMPT=$'%{%f%b%k%}$(build_prompt) 
$(final_prompt) '
