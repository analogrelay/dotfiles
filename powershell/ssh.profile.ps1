$KeysToAdd = @(
    "id_rsa",
    "anurse-docker"
    "anurse-benchmarking"
)

function AddKeyIfNotPresent($KeyFile) {
    # Check if we need to add the main identity to the agent
    $KeyGenInfo = (ssh-keygen -lf $KeyFile)
    if ($KeyGenInfo) {
        $fingerprint = $KeyGenInfo.Split(" ")[1]

        if (ssh-add -l | select-string $fingerprint -SimpleMatch) {
            Write-Host "$KeyFile already registered in SSH agent"
        }
        else {
            ssh-add $KeyFile
        }
    }
    else {
        Write-Host "$KeyFile does not exist"
    }
}

if (Get-Command ssh-agent -ErrorAction SilentlyContinue) {
    Start-SshAgent
    $ssh = (Get-Command ssh.exe).Definition
    $env:GIT_SSH = $ssh

    $KeysToAdd | ForEach-Object {
        $KeyFile = Join-Path (Join-Path $env:USERPROFILE ".ssh") $_
        AddKeyIfNotPresent $KeyFile
    }
}
