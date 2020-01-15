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



# if ($PSVersionTable.Platform -eq "Win32NT") {
#     $sshAgentService = Get-Service ssh-agent -ErrorAction SilentlyContinue
#     if ($sshAgentService) {
#         if ($sshAgentService.StartupType -eq "Disabled") {
#             if (Confirm "SSH Agent disabled" "SSH Agent is disabled, enable it? A UAC prompt is required.") {
#                 $scriptPath = Convert-Path (Join-Path (Split-Path -Parent $PSScriptRoot) "fix-ssh-agent.ps1")
#                 Start-Process -Verb RunAs ((Get-Command pwsh).Definition) -Args "-executionpolicy bypass -noprofile -nologo -file $scriptPath" -Wait
#             }
#         }
#         Start-Service ssh-agent
#         $ssh = (Get-Command ssh.exe).Definition
#         $env:GIT_SSH = $ssh

#         $KeysToAdd | ForEach-Object {
#             $KeyFile = Join-Path (Join-Path $env:USERPROFILE ".ssh") $_
#             AddKeyIfNotPresent $KeyFile
#         }
#     }
# }