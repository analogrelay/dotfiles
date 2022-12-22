if ! type git >/dev/null 2>&1; then
    return
fi

if [ "$CODESPACES" = "true" ]; then
    # Don't do this, we don't have SSH configured in codespaces.
    return
fi

# Check if git is using ssh to clone github.com
if [ "$(git config url."git@github.com:".insteadOf)" != "https://github.com" ]; then
    # Can we SSH to github.com?
    echo "Checking if SSH works..."
    if ssh git@github.com 2>&1 | grep "You've successfully authenticated"; then
        # Ok, configure the override
        git config --file ~/.gitlocal url."git@github.com:".insteadOf "https://github.com"
        # But not for Cargo. It's a pain and we don't need to push to it.
        git config --file ~/.gitlocal url."https://github.com/rust-lang/crates.io-index".insteadOf "https://github.com/rust-lang/crates.io-index"
    fi
fi

signing=false
if [ "$(uname)" = "Darwin" ] && [ -f "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" ]; then
    git config --file ~/.gitlocal gpg."ssh".program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    git config --file ~/.gitlocal gpg.format ssh
    git config --file ~/.gitlocal user.signingkey "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEjRwisd5P4UEZtXMO19uk+ly2Jbu9LgLmGmlmWz7Mbh"
    signing=true

    if [ ! -f "~/.ssh/config.d/1password" ]; then
        mkdir -p ~/.ssh/config.d
        cat > ~/.ssh/config.d/1password <<EOF
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
EOF
    fi
else
    echo "Not configuring signing"
fi

if $signing; then
    git config --file ~/.gitlocal commit.gpgsign true
    git config --file ~/.gitlocal tag.gpgsign true
    git config --file ~/.gitlocal merge.gpgsign true
    git config --file ~/.gitlocal rebase.gpgsign true
fi
