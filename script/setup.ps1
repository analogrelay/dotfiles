param(
    [Parameter(Mandatory = $false)][string[]]$Profiles
)

if ($PSVersionTable.PSEdition -ne "Core") {
    throw "Dotfiles requires PowerShell Core"
}

if ($PSVersionTable.Platform -eq "Unix") {
    throw "Use the 'install.sh' script to install on Unix. After installing, the PowerShell profile in .dotfiles WILL STILL apply to PowerShell on Unix!"
}

$env:HOME = [Environment]::GetFolderPath("UserProfile")

$DotFilesRoot = Split-Path -Parent $PSScriptRoot

. "$DotFilesRoot/ps1/utils.ps1"

function Install-DotFiles() {
    $DevModeRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"

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
    if ($IsWindows) {
        $RegKeyPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock"
        if (!(Test-Path $RegKeyPath)) {
            New-Item -Path $RegKeyPath -ItemType Directory -Force
        }

        if ((Get-ItemProperty $RegKeyPath).AllowDevelopmentWithoutDevLicense -ne 1) {
            Doing "Enabling Developer Mode..."
            New-ItemProperty -Path $RegKeyPath -Name AllowDevelopmentWithoutDevLicense -PropertyType DWORD -Value 1 
        }
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

    if ($Profiles.Count -gt 0) {
        Write-Host "Installing profiles: $Profiles"
    }
} catch {
    throw
}
finally {
    Remove-Item -Path variable:\DotFilesInstalling -ErrorAction SilentlyContinue
    if ($Debug) {
        $DebugPreference = $oldDebugPref
    }
}