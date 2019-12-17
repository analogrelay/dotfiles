Write-Host "Running DotFiles Profile..."

# Load config and utils
. "$PSScriptRoot\..\config.ps1"

$env:HOME = [Environment]::GetFolderPath("UserProfile")

$DotFilesRoot = Split-Path -Parent $PSScriptRoot
$DotFilesBinPath = Join-Path $DotFilesRoot "bin"
$DotFilesPs1Path = Join-Path $DotFilesRoot "ps1"

# Configure Module Path
$LocalModulePath = Join-Path $PSScriptRoot "modules"
$env:PSModulePath = "$(Convert-Path $LocalModulePath)$([IO.Path]::PathSeparator)$env:PSModulePath"

# Load Posh-Git and Oh-My-Posh
$DotFilesPowerShellModules | ForEach-Object {
    if (!(Get-Module -ListAvailable $_)) {
        Write-Host "Installing module '$_' ..."
        Install-Module $_ -Scope CurrentUser
    }
    Import-Module $_
}

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
    Add-PathVariable -Prepend "$env:HOME\.dotnet\x64"
}
else {
    Add-PathVariable -Prepend "$env:HOME\.dotnet"
}