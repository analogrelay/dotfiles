#!/usr/bin/env bash

if ! type -p gpg >/dev/null 2>&1; then
    return
fi

if ! type -p op >/dev/null 2>&1; then
    return
fi

KEYID=42ECAC889F98413E5C23970604277A6059CB213C
KEYEMAIL="git@analogrelay.net"

if ! gpg --list-key "$KEYID" 2>/dev/null >/dev/null; then
    gpg --import "~/.gnupg/${KEYEMAIL}_gitsigning.public.gpg-key"
fi

if ! gpg --list-secret-keys $KEYID 2>&1 >/dev/null; then
    if [ -z "$OP_SESSION_stanton_nurse" ]; then
        echo "Signing in to 1password"
        eval $(op signin stanton-nurse.1password.com andrew@stanton-nurse.com)
    fi

    op get document "${KEYEMAIL}_gitsigning.private.gpg-key" > "~/.gnupg/${KEYEMAIL}_gitsigning.private.gpg-key"
    gpg --import "~/.gnupg/${KEYEMAIL}_gitsigning.private.gpg-key"
    rm "~/.gnupg/${KEYEMAIL}_gitsigning.private.gpg-key"
fi

git config --file ~/.gitlocal user.signingkey "$KEYID"
git config --file ~/.gitlocal commit.gpgsign true