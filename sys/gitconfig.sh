#!/usr/bin/env bash

user () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd)

git_credential='cache'
if [ "$(uname -s)" == "Darwin" ]
then
    git_credential='osxkeychain'
fi

user ' - What is your github author name?'
read -e git_authorname
user ' - What is your github author email?'
read -e git_authoremail

editor='vi'
mergetool='vimdiff'
difftool='vimdiff'

sed -e "s/AUTHORNAME/$git_authorname/g" \
    -e "s/AUTHOREMAIL/$git_authoremail/g" \
    -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" \
    -e "s/EDITOR/$editor/g" \
    -e "s/MERGETOOL/$mergetool/g" \
    -e "s/DIFFTOOL/$difftool/g" \
    git/gitconfig.template > git/gitconfig