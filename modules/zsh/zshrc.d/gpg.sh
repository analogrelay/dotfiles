#!/usr/bin/env bash

if ! type -p gpg >/dev/null 2>&1; then
    return
fi

if ! type -p op >/dev/null 2>&1; then
    return
fi

keys=("git@analogrelay.net" "andrew@stanton-nurse.com")

if ! gpg --list-key "$KEYID" 2>/dev/null >/dev/null; then
    gpg --import "$HOME/.gnupg/${KEYEMAIL}_gitsigning.public.gpg-key"
fi

for key in $keys; do
    if ! gpg --list-secret-keys $key 2>&1 >/dev/null; then
        bigheading "gpg key $key not found"
        if read -q "choice?import key for $key now? [y/N]"; then
            if [ -z "$OP_SESSION_stanton_nurse" ]; then
                heading "signing in to 1password"
                eval $(op signin stanton-nurse.1password.com andrew@stanton-nurse.com)
            fi

            heading "fetching gpg private keys"
            op get document "${key}_gitsigning.private.gpg-key" > "$HOME/.gnupg/${key}_gitsigning.private.gpg-key"
            gpg --import "$HOME/.gnupg/${key}_gitsigning.private.gpg-key"
            rm "$HOME/.gnupg/${key}_gitsigning.private.gpg-key"
        fi
    fi
done

git config --file ~/.gitlocal user.signingkey "42ECAC889F98413E5C23970604277A6059CB213C"
git config --file ~/.gitlocal commit.gpgsign true