# This script should work on Windows PowerShell to facilitate bootstrapping.

# Bootstraps the installation of the dotfiles scripts from scratch
$ErrorPreference = "Stop"

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

if (($PSVersionTable.PSEdition -eq "Core") -and ($PSVersionTable.Platform -ne "Win32NT")) {
    throw "The bootstrap.ps1 script is for Windows only. Use bootstrap.sh on macOS/Linux. It will still configure PowerShell for you!"
}

# Utility functions copied from other places to keep this script self-contained.
function Doing($action) {
    Write-Host -ForegroundColor Green $action
}

function AlreadyDone($action) {
    Wrhite-Host -ForegroundColor Magenta $action
}

function Test-Command($CommandName) {
    # Calling Get-Command, even with ErrorAction SilentlyContinue, spams
    # $error with errors. This avoids that.
    !!(Get-Command "$CommandName*" | 
        Where-Object {
            [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -eq $CommandName
        })
}

# Configure scoop
if (!(Test-Command scoop)) {
    Doing "Installing Scoop..."

    # We check the install script against a known hash to make sure it's what we think it is.
    $ScoopInstallerHash = "M3y+81KJQhr+CMw1cTL7TG8kbXYp4yLg9jiwZVgWSisKGuKFb6EMPwfgRIbiQQ1t+L0LVFHmi4Ua9YoKq/RIbA==";
    $client = New-Object System.Net.WebClient
    $content = $client.DownloadString("https://get.scoop.sh");
    $sha = [System.Security.Cryptography.SHA512]::Create()
    $actualHash = [Convert]::ToBase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($content)))

    if ($actualHash -ne $ScoopInstallerHash) {
        throw "Scoop installed did not match hash! Expected '$ScoopInstallerHash' but got '$actualHash'. Go to https://get.scoop.sh and check the script for changes and update the hash"
    }

    Invoke-Expression $content
}
else {
    AlreadyDone "Using already-installed Scoop..."
}

# Install git so we can get the dotfiles repo down
if (!(Test-Command git)) {
    Doing -ForegroundColor Green "Installing Git."
    scoop install git
}
else {
    AlreadyDone "Using already-installed Scoop..."
}

# Git won't be in the PATH yet
if (Test-Command git) {
    $gitExe = "git"
}
else {
    $gitExe = scoop which git
    if (!(Test-Path $gitExe)) {
        throw "Could not find 'git.exe' despite it being installed!"
    }
}

$DotfilesPath = Join-Path $env:USERPROFILE ".dotfiles"

if (Test-Path $DotfilesPath) {
    Doing "Updating the dotfiles."
    Set-Location $DotfilesPath
    & "$gitExe" pull --rebase --autostash
}
else {
    Doing "Cloning the dotfiles."
    & "$gitExe" clone https://github.com/anurse/dotfiles.git $DotfilesPath
}

# Install pwsh if necessary
if (!(Test-Command pwsh)) {
    Doing "Installing PowerShell Core..."
    # Don't use scoop to install pwsh. Use the msix
    $release = (Invoke-WebRequest "https://api.github.com/repos/powershell/powershell/releases/latest").Content | ConvertFrom-Json
    $msixAsset = $release.assets | Where-Object { $_.name.EndsWith("-win-x64.msix") }

    # Download the MSIX
    $downloadedMsix = Join-Path ([System.IO.Path]::GetTempPath()) "powershell-installer.msix"
    if (Test-Path $downloadedMsix) {
        Remove-Item $downloadedMsix
    }
    Invoke-WebRequest $msixAsset.browser_download_url -OutFile $downloadedMsix
    Add-AppxPackage -Path $downloadedMsix
}
else {
    AlreadyDone "Using already-installed PowerShell Core..."
    $pwshExe = "pwsh"
}

Doing "Launching setup script!"
$setupScriptPath = Join-Path $DotfilesPath "/script/setup.ps1"
& "$pwshExe" "$setupScriptPath"