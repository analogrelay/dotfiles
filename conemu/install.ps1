if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

$dotfilesConEmuPath = Join-Path $DotfilesRoot "conemu"
$dotfilesConEmuXml = Join-Path $dotfilesConEmuPath "ConEmu.xml"
$conEmuPath = Join-Path $env:APPDATA "ConEmu.xml"

if (Test-Path $conEmuPath) {
    if (!(Confirm "Remove existing ConEmu settings" "A ConEmu settings file already exists in '$conEmuPath'. Remove it?")) {
        throw "User cancelled installation"
    }
    Remove-Item $conEmuPath
}

New-Item -Path $conEmuPath -ItemType SymbolicLink -Value $dotfilesConEmuXml | Out-Null