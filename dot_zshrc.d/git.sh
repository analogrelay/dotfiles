if ! type git >/dev/null 2>&1; then
    return
fi

if [ "$CODESPACES" = "true" ]; then
    # Don't do this, we don't have SSH configured in codespaces.
    return
fi

# Check if git is using ssh to clone github.com
if [ "$(git config url."git@github.com:".insteadOf)" = "https://github.com" ]; then
    return
fi

# Can we SSH to github.com?
if ssh git@github.com 2>&1 | grep "You've successfully authenticated"; then
    # Ok, configure the override
    git config --file ~/.gitlocal url."git@github.com:".insteadOf "https://github.com"
    # But not for Cargo. It's a pain and we don't need to push to it.
    git config --file ~/.gitlocal url."https://github.com/rust-lang/crates.io-index".insteadOf "https://github.com/rust-lang/crates.io-index"
fi