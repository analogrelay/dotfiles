$KeysToAdd = @(
    "id_rsa"
)

function AddKeyIfNotPresent($KeyFile) {
    # Check if we need to add the main identity to the agent
    $KeyGenInfo = (ssh-keygen -lf $KeyFile)
    if ($KeyGenInfo) {
        $fingerprint = $KeyGenInfo.Split(" ")[1]

        if (!(ssh-add -l | select-string $fingerprint -SimpleMatch)) {
            ssh-add $KeyFile
        }
    }
    else {
        Write-Warning "$KeyFile does not exist"
    }
}

if ($PSVersionTable.Platform -eq "Win32NT") {
    $sshAgentService = Get-Service ssh-agent -ErrorAction SilentlyContinue
    if ($sshAgentService) {
        if ($sshAgentService.StartupType -eq "Disabled") {
            Set-Service $sshAgentService -StartupType Automatic
        }

        Start-Service ssh-agent
        $ssh = (Get-Command ssh.exe).Definition
        $env:GIT_SSH = $ssh

        $KeysToAdd | ForEach-Object {
            $KeyFile = Join-Path (Join-Path $env:USERPROFILE ".ssh") $_
            AddKeyIfNotPresent $KeyFile
        }
    }
}