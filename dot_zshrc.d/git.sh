if ! type git >/dev/null 2>&1; then
    return
fi

if [ "$CODESPACES" = "true" ]; then
    # Don't do this, we don't have SSH configured in codespaces.
    return
fi

# Prime the host keys file
ensure_host_key() {
    type="$1"
    key="$2"
    if [ ! -e ~/.ssh/known_hosts ]; then
        echo "$type $key" > ~/.ssh/known_hosts
    elif ! cat ~/.ssh/known_hosts | grep "$type" >/dev/null 2>&1; then
        echo "$type $key" >> ~/.ssh/known_hosts
    fi
}

ensure_host_key "github.com ssh-ed25519" "AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
ensure_host_key "github.com ecdsa-sha2-nistp256" "AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
ensure_host_key "github.com ssh-rsa" "AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="

# Check if git is using ssh to clone github.com
if [ "$(git config url."git@github.com:".insteadOf)" != "https://github.com" ]; then
    # Can we SSH to github.com?
    if ssh git@github.com 2>&1 | grep "You've successfully authenticated"; then
        # Ok, configure the override
        git config --file ~/.gitlocal url."git@github.com:".insteadOf "https://github.com"
        # But not for Cargo. It's a pain and we don't need to push to it.
        git config --file ~/.gitlocal url."https://github.com/rust-lang/crates.io-index".insteadOf "https://github.com/rust-lang/crates.io-index"
    fi
fi

OP_PATH=""
if [ "$(uname)" = "Darwin" ]; then
    OP_PATH="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
elif cat /proc/version | grep microsoft >/dev/null 2>&1; then
    if [ -e "/mnt/c/Users/analogrelay/AppData/Local/1Password/app/8/op-ssh-sign.exe" ]; then
        OP_PATH="/mnt/c/Users/analogrelay/AppData/Local/1Password/app/8/op-ssh-sign.exe"
    elif [ -e "/mnt/c/Users/andre/AppData/Local/1Password/app/8/op-ssh-sign.exe" ]; then
        OP_PATH="/mnt/c/Users/andre/AppData/Local/1Password/app/8/op-ssh-sign.exe"
    fi
fi

signing=false
if [ -n "$OP_PATH" ] && [ -e "$OP_PATH" ]; then
    git config --file ~/.gitlocal gpg."ssh".program "$OP_PATH"
    git config --file ~/.gitlocal gpg.format ssh
    git config --file ~/.gitlocal user.signingkey "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEjRwisd5P4UEZtXMO19uk+ly2Jbu9LgLmGmlmWz7Mbh"
    signing=true
fi

if type ssh-agent >/dev/null 2>&1; then
    eval $(ssh-agent -s)
    [ -e ~/.ssh/id_rsa ] && ssh-add ~/.ssh/id_rsa
    [ -e ~/.ssh/id_ed25519 ] && ssh-add ~/.ssh/id_ed25519
fi

if $signing; then
    git config --file ~/.gitlocal commit.gpgsign true
    git config --file ~/.gitlocal tag.gpgsign true
    git config --file ~/.gitlocal merge.gpgsign true
    git config --file ~/.gitlocal rebase.gpgsign true
fi
