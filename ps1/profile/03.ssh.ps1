. Join-Path (Split-Path -Parent $PSScriptRoot) "utils.ps1"

$KeysToAdd = @(
    "id_rsa"
)

if ($IsWindows) {
    $sshAgent = Join-Path $env:HOME "scoop\apps\git\current\usr\bin\ssh-agent.exe"
    $sshKeygen = Join-Path $env:HOME "scoop\apps\git\current\usr\bin\ssh-keygen.exe"
    $sshAdd = Join-Path $env:HOME "scoop\apps\git\current\usr\bin\ssh-add.exe"
    $env:GIT_SSH = Join-Path $env:HOME "scoop\apps\git\current\usr\bin\ssh.exe"
}

if (Test-Command ssh-agent) {
    $sshAgent = "ssh-agent"
    $sshKeygen = "ssh-keygen"
    $sshAdd = "ssh-add"
}

function AddKeyIfNotPresent($KeyFile) {
    # Check if we need to add the main identity to the agent
    $KeyGenInfo = (& "$sshKeygen" -lf $KeyFile)
    if ($KeyGenInfo) {
        $fingerprint = $KeyGenInfo.Split(" ")[1]

        if (!(& "$sshAdd" -l | select-string $fingerprint -SimpleMatch)) {
            & "$sshAdd" $KeyFile
        }
    }
    else {
        Write-Warning "$KeyFile does not exist"
    }
}

if (!(Test-Path env:\SSH_AUTH_SOCK) -and $sshAgent) {
    & "$sshAgent" | ForEach-Object {
        if($_ -match "([A-Za-z0-9_]*)=([^;]*); export \1;") { 
            Set-Content "env:\$($matches[1])" $matches[2]
        }
    }

    if ($sshKeygen) {
        $KeysToAdd | ForEach-Object {
            $KeyFile = Join-Path (Join-Path $env:HOME ".ssh") $_
            AddKeyIfNotPresent $KeyFile
        }
    }
}