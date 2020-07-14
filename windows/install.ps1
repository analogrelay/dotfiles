param(
    [Parameter(Mandatory = $false)][switch]$WhatIf
)

if(!$IsWindows -and !$WhatIf) {
    throw "Cannot actually install components on non-Windows platforms."
}

Write-Debug "Loading scoopfile..."
. "$PSScriptRoot/Scoopfile-Sdk.ps1"
. "$PSScriptRoot/scoopfile.ps1"
$Definitions = Get-Definitions

Write-Debug "Running items..."
$Definitions | ForEach-Object {
    $name = $_.Name
    Write-Debug "Processing $name"
    $isInstalled = $false
    if ($_.Check -ne $null) {
        Write-Debug "Running checker for $name ..."
        $isInstalled = & $_.Check $_
    } else {
        Write-Debug "No checker for $name!"
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
                Write-Debug "Running installer for $name ..."
                & $_.Install $_
            } catch {
                Write-Error "Installing $name failed with $($error[0])"
            }
        }
    }
}