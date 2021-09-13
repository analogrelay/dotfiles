#!/usr/bin/env bash

keyid="42ECAC889F98413E5C23970604277A6059CB213C"

if [ "$CODESPACES" = "true" ] || type gpg >/dev/null 2>&1; then
    git config --file ~/.gitlocal commit.gpgsign true

    # Use default signing key if present
    if gpg --list-secret-keys "$keyid" >/dev/null 2>&1; then
        git config --file ~/.gitlocal user.signingkey "$keyid"
    fi
fi