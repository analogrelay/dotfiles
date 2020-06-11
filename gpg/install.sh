if ! has op; then
    echo "Cannot load gpg, 1password-cli is not installed."
    return
fi

KEYID=B86EA7CF15CD9B8CF46BA31862ADE1FEC51F9A1A

link_file ~/.dotfiles/gpg/andrew@stanton-nurse.com_gitsigning.public.gpg-key ~/.gnupg/andrew@stanton-nurse.com_gitsigning.public.gpg-key
gpg --import ~/.gnupg/andrew@stanton-nurse.com_gitsigning.public.gpg-key

if ! gpg --list-secret-keys $KEYID 2>&1 >/dev/null; then
    if [ -z "$OP_SESSION_stanton_nurse" ]; then
        eval $(op signin stanton-nurse.1password.com andrew@stanton-nurse.com)
    fi

    op get document "andrew@stanton-nurse.com_gitsigning.private.gpg-key" > ~/.gnupg/andrew@stanton-nurse.com_gitsigning.private.gpg-key
    gpg --import ~/.gnupg/andrew@stanton-nurse.com_gitsigning.private.gpg-key
    rm ~/.gnupg/andrew@stanton-nurse.com_gitsigning.private.gpg-key
fi

git config --file ~/.gitauthor user.signingkey "$KEYID"