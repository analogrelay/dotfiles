if (Get-Command ssh-agent -ErrorAction SilentlyContinue) {
    Start-SshAgent
    $ssh = (Get-Command ssh.exe).Definition
    $env:GIT_SSH=$ssh

    $MainKey = Join-Path $env:USERPROFILE ".ssh\id_rsa"

    # Check if we need to add the main identity to the agent
    $fingerprint = (ssh-keygen -lf $MainKey).Split(" ")[1]

    if(ssh-add -l | select-string $fingerprint) {
        Write-Host "$MainKey already registered in SSH agent"
    } else {
        ssh-add $MainKey
    }
}
