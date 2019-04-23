param(
    [switch]$Debug
)

if ($PSVersionTable.PSEdition -ne "Core") {
    throw "Dotfiles requires PowerShell Core"
}

$env:HOME = [Environment]::GetFolderPath("UserProfile")

. "$PSScriptRoot/ps1/utils.ps1"

function Install-DotFiles() {
    $DevModeRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"

    $DotFilesRoot = Convert-Path $PSScriptRoot

    # Dot-source the config file
    . "$DotFilesRoot/config.ps1"

    function Test-DeveloperMode() {
        if (Test-Path $DevModeRegPath) {
            (Get-ItemProperty $DevModeRegPath).AllowDevelopmentWithoutDevLicense -eq 1
        }
        else {
            $false
        }
    }

    # Check Windows Pre-requisites
    if ($PSVersionTable.Platform -eq "Win32NT") {
        $Global:PlatformIsWindows = $true
        Write-Debug "Running on Windows"
        if (Test-DeveloperMode) {
            Write-Debug "Developer mode is ENABLED!"
        }
        else {
            Write-Host "Developer mode must be enabled to create symbolic links."
            Write-Host "Launching Windows Settings to enable Developer Mode."
            Write-Host "Re-run this script after enabling Developer Mode to continue."
            Start-Process "ms-settings:developers"
            return
        }
    }
    else {
        $Global:PlatformIsOther = $true
    }

    # Run all Install scripts
    $DotFilesInstallScripts | ForEach-Object {
        $path = Join-Path $PSScriptRoot $_
        Write-Debug "Running Install Script $path ..."
        try {
            & "$path"
        }
        catch {
            Write-Error -ErrorRecord $Error[0]
            Write-Debug "Error during installation."
        }
    }
}

$oldDebugPref = $DebugPreference
if ($Debug) {
    $DebugPreference = "Continue"
}

try {
    $DotFilesInstalling = $true
    Install-DotFiles
}
finally {
    Remove-Item -Path variable:\DotFilesInstalling -ErrorAction SilentlyContinue
    if ($Debug) {
        $DebugPreference = $oldDebugPref
    }
}