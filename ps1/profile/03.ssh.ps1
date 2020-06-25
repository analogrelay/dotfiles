. Join-Path (Split-Path -Parent $PSScriptRoot) "utils.ps1"

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

if (!(Test-Path env:\SSH_AUTH_SOCK)) {
    if ($PSVersionTable.Platform -eq "Win32NT") {
        $gitBin = Join-Path $env:HOME "scoop\apps\git\current\usr\bin"
        if (Test-Path $gitBin) {
            Add-PathVariable -Prepend $gitBin
        }
    }

    if (Test-Command ssh-agent) {
        ssh-agent | ForEach-Object {
            if($_ -match "([A-Za-z0-9_]*)=([^;]*); export \1;") { 
                Set-Content "env:\$($matches[1])" $matches[2]
            }
        }

        $KeysToAdd | ForEach-Object {
            $KeyFile = Join-Path (Join-Path $env:HOME ".ssh") $_
            AddKeyIfNotPresent $KeyFile
        }
    }

    $ssh = (Get-Command ssh).Definition
    $env:GIT_SSH = $ssh
}