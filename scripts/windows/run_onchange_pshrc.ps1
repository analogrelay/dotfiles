# Set up powershell
$script = @"
if(Test-Path `$env:USERPROFILE) {
    `$pshrc = Join-Path `$env:USERPROFILE ".pwshrc.ps1"
} elseif(Test-Path `$env:HOME) {
    `$pshrc = Join-Path `$env:HOME ".pwshrc.ps1"
}

if(Test-Path `$pshrc) {
    . `$pshrc
}
"@

$profile_root = Split-Path -Parent (Split-Path -Parent $profile)
if(!(Test-Path $profile_root)) {
    New-Item -Type Directory $profile_root | Out-Null
}

$pwsh_root = Join-Path $profile_root "PowerShell"
if(!(Test-Path $pwsh_root)) {
    New-Item -Type Directory $pwsh_root | Out-Null
}

$winpowershell_root = Join-Path $profile_root "WindowsPowerShell"
if(!(Test-Path $winpowershell_root)) {
    New-Item -Type Directory $pwsh_root | Out-Null
}

$script > (Join-Path $pwsh_root "profile.ps1")
$script > (Join-Path $winpowershell_root "profile.ps1")