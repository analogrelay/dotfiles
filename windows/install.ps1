param(
    [Parameter(Mandatory = $false)][switch]$WhatIf
)

$Definitions = & "$PSScriptRoot/Get-Scoopfile.ps1"

$Definitions | ForEach-Object {
    $name = $_.Name
    $shouldInstall = $true
    if ($_.Check -ne $null) {
        $shouldInstall = & $_.Check
    }

    if ($shouldInstall) {
        Write-Host -ForegroundColor Green "Installing $name ..."
        if ($_.Install -eq $null) {
            Write-Error "No install command defined for $name!"
        }
        elseif (!$WhatIf) {
            try {
                & $_.Install
            } catch {
                Write-Error "Installing $name failed with $($error[0])"
            }
        }
    }
    else {
        Write-Host "Using $name"
    }
}