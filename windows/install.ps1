param(
    [Parameter(Mandatory = $false)][switch]$WhatIf
)

$Definitions = & "$PSScriptRoot/Get-Scoopfile.ps1"

$Definitions | ForEach-Object {
    $name = $_.Name
    $isInstalled = $false
    if ($_.Check -ne $null) {
        $isInstalled = & $_.Check
    }

    if ($isInstalled) {
        Write-Host "Using $name"
    }
    else {
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
}