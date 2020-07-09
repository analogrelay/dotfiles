if ! has gpg; then
    echo "Cannot load gpg, it is not installed."
    return
fi

if ! has op; then
    echo "Cannot load gpg, 1password-cli is not installed."
    return
fi

KEYID=B86EA7CF15CD9B8CF46BA31862ADE1FEC51F9A1A

[ -d ~/.gnupg ] || mkdir ~/.gnupg
link_file ~/.dotfiles/gpg/andrew@stanton-nurse.com_gitsigning.public.gpg-key ~/.gnupg/andrew@stanton-nurse.com_gitsigning.public.gpg-key

if gpg --list-key "$KEYID" 2>/dev/null >/dev/null; then
    echo "Key is already loaded!"
else
    gpg --import ~/.gnupg/andrew@stanton-nurse.com_gitsigning.public.gpg-key

    if ! gpg --list-secret-keys $KEYID 2>&1 >/dev/null; then
        if [ -z "$OP_SESSION_stanton_nurse" ]; then
            eval $(op signin stanton-nurse.1password.com andrew@stanton-nurse.com)
        fi

        op get document "andrew@stanton-nurse.com_gitsigning.private.gpg-key" > ~/.gnupg/andrew@stanton-nurse.com_gitsigning.private.gpg-key
        gpg --import ~/.gnupg/andrew@stanton-nurse.com_gitsigning.private.gpg-key
        rm ~/.gnupg/andrew@stanton-nurse.com_gitsigning.private.gpg-key
    fi
fi

git config --file ~/.gitlocal user.signingkey "$KEYID"
git config --file ~/.gitlocal commit.gpgsign true