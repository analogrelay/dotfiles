# Bootstraps the installation of the dotfiles scripts from scratch

function Test-Command($CommandName) {
    # Calling Get-Command, even with ErrorAction SilentlyContinue, spams
    # $error with errors. This avoids that.
    !!(Get-Command "$CommandName*" | 
        Where-Object {
            [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -eq $CommandName
        })
}

# Ensure scoop and git are installed
if (!(Test-Command "scoop")) {
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

if (!(Test-Command "git")) {
    scoop install git
}

# First, check if it's already cloned
$DotFilesRoot = Join-Path ([Environment]::GetFolderPath("UserProfile")) ".dotfiles"
if (!(Test-Path $DotFilesRoot)) {
    # It doesn't exist, clone it
    git clone "https://github.com/anurse/dotfiles" $DotFilesRoot
}

$InstallScript = Join-Path $DotFilesRoot "install.ps1"

# Ensure we have powershell core installed
if ($PSVersionTable.PSEdition -ne "Core") {
    if (!(Test-Command pwsh)) {
        scoop install pwsh
    }
    pwsh $InstallScript
}
else {
    & $InstallScript
}