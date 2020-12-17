if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

if(!(Test-Command colortool)) {
    scoop install colortool
}

$TempFile = Join-Path ([System.IO.Path]::GetTempPath()) "primeterm.ini"
try {
    & "$DotFilesRoot/terminal/ConvertTo-ColorToolIni.ps1" "$DotFilesRoot/terminal/PrimeTerm.json" > $TempFile
    colortool -q -b $TempFile
} finally {
    Remove-Item -Force -ErrorAction SilentlyContinue $TempFile
}

# Configure profiles script
$ParentPath = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$DestPath = Join-Path $ParentPath "settings.json"
$SourcePath = Convert-Path (Join-Path $PSScriptRoot "settings.json")
New-Link -Target $SourcePath -Destination $DestPath

if(!(Get-Command wt.exe -ErrorAction SilentlyContinue)) {
    Write-Host -ForegroundColor Yellow "Windows Terminal is not installed. Install it from the Microsoft Store!"
}