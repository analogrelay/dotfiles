# Find Git Unix Tools and put them on the path
if (!(Get-Command ssh-agent -ErrorAction SilentlyContinue)) {
    $ScoopPath = Join-Path $env:USERPROFILE "scoop"
    if (Test-Path $ScoopPath) {
        $GitSshBin = "$ScoopPath\apps\git\current\usr\bin"
        if (Test-Path $GitSshBin) {
            $env:PATH = "$env:PATH;$GitSshBin"
        }
    }
}

$KeysToAdd = @(
    "id_rsa",
    "anurse-docker"
)

function AddKeyIfNotPresent($KeyFile) {
    # Check if we need to add the main identity to the agent
    $fingerprint = (ssh-keygen -lf $KeyFile).Split(" ")[1]

    if(ssh-add -l | select-string $fingerprint -SimpleMatch) {
        Write-Host "$KeyFile already registered in SSH agent"
    } else {
        ssh-add $KeyFile
    }
}


if (Get-Command ssh-agent -ErrorAction SilentlyContinue) {
    Start-SshAgent
    $ssh = (Get-Command ssh.exe).Definition
    $env:GIT_SSH=$ssh

    $KeysToAdd | ForEach-Object {
        $KeyFile = Join-Path (Join-Path $env:USERPROFILE ".ssh") $_
        AddKeyIfNotPresent $KeyFile
    }
}
