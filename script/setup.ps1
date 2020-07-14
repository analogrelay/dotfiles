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

    # Configure SSH if necessary
    if (!(Test-Path "$env:USERPROFILE/.ssh/id_rsa")) {
        Write-Host "Creating SSH identity"
        ssh-keygen -t rsa -b 4096 -C "$(hostname)"

        Get-Content "$env:USERPROFILE/.ssh/id_rsa.pub" | clip.exe
        Write-Host "SSH Public Key is now in the clipboard"
        Write-Host "Navigate to https://github.com/settings/keys to install it."
        Read-Host "Press ENTER when you've configured it in GitHub ..."
    }

    git --git-dir "$DotFilesRoot\.git" --work-tree "$DotFilesRoot" remote set-url origin "$DotFilesRepo"

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
        $path = Join-Path $DotFilesRoot $_
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