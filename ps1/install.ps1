if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

Write-Host "Installing PowerShell Profile ..."

if (Test-Path $Profile) {
    if (!(Confirm "Remove existing profile" "A profile script already exists in '$Profile'. Remove it?")) {
        throw "User cancelled installation"
    }
}

$Ps1Root = Join-Path $DotFilesRoot "ps1"
$DotFilesProfile = Join-Path $Ps1Root "profile.ps1"

". $DotFilesProfile" | Out-File -FilePath $profile -Encoding UTF8

# Install Modules
Write-Host "Installing PowerShell Modules ..."
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck