autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

MN_BG=6
MN_FG=0
DIR_BG=11
DIR_FG=0
GIT_CLEAN_BG=10
GIT_CLEAN_FG=0
GIT_DIRTY_BG=9
GIT_DIRTY_FG=0

DIR_SYMBOL="\ue5ff"
BRANCH_SYMBOL="\ue0a0"
ARROW_SYMBOL="\ue0b0"

MACHINE_TYPE_SYMBOL=
UNAME=$(uname)
if [[ "$UNAME" == "Darwin" ]]; then
    MACHINE_TYPE_SYMBOL="\ue711"
elif [[ "$WSL" == "1" ]]; then
    MACHINE_TYPE_SYMBOL="\ue70f"
else
    MACHINE_TYPE_SYMBOL="\ue712"
fi

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_dirty() {
  if $(! $git status -s &> /dev/null)
  then
    echo " %F{$DIR_BG}%k$ARROW_SYMBOL%f"
  else
    if [[ $($git status --porcelain) == "" ]]
    then
      echo " %F{$DIR_BG}%K{$GIT_CLEAN_BG}$ARROW_SYMBOL %K{$GIT_CLEAN_BG}%F{$GIT_CLEAN_FG}$(git_prompt_info)%k%F{$GIT_CLEAN_BG}$ARROW_SYMBOL%f"
    else
      echo " %F{$DIR_BG}%K{$GIT_DIRTY_BG}$ARROW_SYMBOL %K{$GIT_DIRTY_BG}%F{$GIT_DIRTY_FG}$(git_prompt_info)%k%F{$GIT_DIRTY_BG}$ARROW_SYMBOL%f"
    fi
  fi
}

git_prompt_info () {
 ref=$($git symbolic-ref HEAD 2>/dev/null) || return
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
 echo "$BRANCH_SYMBOL ${ref#refs/heads/}"
}

directory_name() {
  echo " $DIR_SYMBOL %K{$DIR_BG}%F{$DIR_FG}%~%\/"
}

machine_name() {
  echo -e "%K{$MN_BG}%F{$MN_FG} $MACHINE_TYPE_SYMBOL $(hostname) %K{$DIR_BG}%F{$MN_BG}\ue0b0"
}

export PROMPT=$'\n$(machine_name)$(directory_name)$(git_dirty)%k%f\nzsh› '
set_prompt () {
  export RPROMPT="%{$fg_bold[cyan]%}%{$reset_color%}"
}

precmd() {
  title "zsh" "%m" "%55<...<%~"
  set_prompt
}
