# Prime the host keys file
$sshdir = Join-Path $env:HOME ".ssh"
if (!(Test-Path $sshdir)) {
    New-Item -Type Directory $sshdir | Out-Null
}

function Ensure-HostKey($hostname, $type, $key) {
    $known_hosts = Join-Path $sshdir "known_hosts"
    if (!(Test-Path $known_hosts) -or !(Get-Content $known_hosts | Select-String -Pattern "$hostname $type")) {
        Add-Content -Encoding UTF8 $known_hosts "$hostname $type $key"
    }
}

Ensure-HostKey "github.com" "ssh-ed25519" "AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
Ensure-HostKey "github.com" "ecdsa-sha2-nistp256" "AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
Ensure-HostKey "github.com" "ssh-rsa" "AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="

# Use OpenSSH if installed
$gitlocal = Join-Path "$env:HOME" ".gitlocal"
if (Test-Path "C:/Windows/System32/OpenSSH/ssh.exe") {
    git config --file $gitlocal core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"
}

if ((git config url."git@github.com:".insteadOf) -ne "https://github.com") {
    if (ssh git@github.com 2>&1 | select-string "You've successfully authenticated") {
        # Ok, configure the override
        git config --file $gitlocal url."git@github.com:".insteadOf "https://github.com"
        # But not for Cargo. It's a pain and we don't need to push to it.
        git config --file $gitlocal url."https://github.com/rust-lang/crates.io-index".insteadOf "https://github.com/rust-lang/crates.io-index"
    }
}

$op_path = Join-Path $env:USERPROFILE "AppData\Local\1Password\app\8\op-ssh-sign.exe"
if(Test-Path $op_path) {
    git config --file $gitlocal gpg."ssh".program "$op_path"
    git config --file $gitlocal gpg.format ssh
    git config --file $gitlocal user.signingkey "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEjRwisd5P4UEZtXMO19uk+ly2Jbu9LgLmGmlmWz7Mbh"
    git config --file $gitlocal commit.gpgsign true
    git config --file $gitlocal tag.gpgsign true
    git config --file $gitlocal merge.gpgsign true
    git config --file $gitlocal rebase.gpgsign true
}