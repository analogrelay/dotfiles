if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

Write-Host "Installing PowerShell Profile ..."

if (Test-Path $Profile) {
    if (Confirm "Remove existing profile" "A profile script already exists in '$Profile'. Remove it?") {
        Remove-Item $Profile
    }
}

if (!(Test-Path $Profile)) {
    $ProfileParent = Split-Path -Parent $Profile

    if(!(Test-Path $ProfileParent))
    {
        mkdir $ProfileParent | Out-Null
    }

    $Ps1Root = Join-Path $DotFilesRoot "ps1"
    $DotFilesProfile = Join-Path $Ps1Root "profile.ps1"

    ". $DotFilesProfile" | Out-File -FilePath $profile -Encoding UTF8
}