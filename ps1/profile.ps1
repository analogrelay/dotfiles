Write-Host "Running DotFiles Profile..."

$DotFilesRoot = Split-Path -Parent $PSScriptRoot
$DotFilesBin = Join-Path $DotFilesRoot "bin"

# Load Posh-Git and Oh-My-Posh
Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox

# Things that have to run before the '.profile' scripts
. "$PSScriptROot/path.ps1"

# Enlighten the PATH
Add-PathVariable "$DotFilesRoot\bin"

# Run all the '.profile' scripts in this directory
Get-ChildItem $PSScriptRoot -Filter "*.profile.ps1" | ForEach-Object {
    Write-Debug "Loading profile script: $_"
    . "$($_.FullName)"
}