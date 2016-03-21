if (Get-Command ssh-agent -ErrorAction SilentlyContinue) {
    Start-SshAgent
    $ssh = (Get-Command ssh.exe).Definition
    $env:GIT_SSH=$ssh
}
