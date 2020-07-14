if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

if(!(Test-Command colortool)) {
    scoop install colortool
}

$ColorProfile = "./terminal/PinkTerm.itermcolors"
colortool -q -b $ColorProfile

# Configure profiles script
$ParentPath = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$DestPath = Join-Path $ParentPath "settings.json"
$SourcePath = Convert-Path (Join-Path $PSScriptRoot "settings.json")
New-Link -Target $SourcePath -Destination $DestPath

if(!(Get-AppxPackage "Microsoft.WindowsTerminal")) {
    Write-Host -ForegroundColor Yellow "Windows Terminal is not installed. Install it from the Microsoft Store!"
}