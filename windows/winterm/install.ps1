if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

if(!(Test-Command colortool)) {
    scoop install colortool
}

$ColorProfile = "./terminal/PinkTerm.itermcolors"
colortool -q -b $ColorProfile

# Configure profiles script
$ParentPath = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$TargetPath = Join-Path $ParentPath "settings.json"
$SourcePath = Convert-Path (Join-Path $PSScriptRoot "settings.json")
if(Test-Path $TargetPath) {
    if (Confirm "Remove existing Windows Terminal Profiles" "A Windows Terminal profiles file already exists in '$TargetPath'. Remove it?") {
        Remove-Item $TargetPath
    }
}
if(!(Test-Path $TargetPath)) {
    if(!(Test-Path $ParentPath)) {
        New-Item -ItemType Directory $ParentPath | Out-Null
    }
    New-Item -ItemType SymbolicLink -Target $SourcePath -Path $TargetPath
}

if(!(Get-AppxPackage "Microsoft.WindowsTerminal")) {
    Write-Host -ForegroundColor Yellow "Windows Terminal is not installed. Install it from the Microsoft Store!"
}