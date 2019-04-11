Write-Host "Running DotFiles Profile..."

$env:HOME = [Environment]::GetFolderPath("UserProfile")

$DotFilesRoot = Split-Path -Parent $PSScriptRoot
$DotFilesBinPath = Join-Path $DotFilesRoot "bin"
$DotFilesPs1Path = Join-Path $DotFilesRoot "ps1"

# Load Posh-Git and Oh-My-Posh
Import-Module posh-git
Import-Module oh-my-posh

# Things that have to run before the '.profile' scripts
. "$PSScriptRoot/path.ps1"

# Enlighten the PATH
Add-PathVariable "$DotFilesRoot\bin"

# Run all the '.profile' scripts in this directory
Get-ChildItem $PSScriptRoot -Filter "*.profile.ps1" | ForEach-Object {
    Write-Debug "Loading profile script: $_"
    . "$($_.FullName)"
}

# Run Post-Profile script actions

# Put our dotnet.exe on the path first
if ($PSVersionTable["Platform"] -eq "Win32NT") {
    Add-PathVariable "$env:HOME\.dotnet\x64"
}
else {
    Add-PathVariable "$env:HOME\.dotnet"
}