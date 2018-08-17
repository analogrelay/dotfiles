# Manage PATH variable with functions

function global:Get-PathVariable() {
    $env:PATH.Split([IO.Path]::PathSeparator)
}

function global:Set-PathVariable([Parameter(Mandatory = $true, Position = 0)][string[]]$PathValues) {
    $env:PATH = [string]::Join([IO.Path]::PathSeparator, $PathValues)
}

function global:Test-PathVariable([Parameter(Mandatory = $true, Position = 0)][string]$Path) {
    @(Get-PathVariable) -icontains $Path
}

function global:Add-PathVariable([Parameter(Mandatory = $true, Position = 0)][string]$Path, [switch]$Prepend) {
    if (Test-PathVariable $Path) {
        Write-Verbose "Ignoring request to add '$Path' to PATH environment variable, it already exists"
    }

    if ($Prepend) {
        $env:PATH = "$Path;$env:PATH"
    }
    else {
        $env:PATH = "$env:PATH;$Path"
    }
}

function global:Remove-PathVariable([Parameter(Mandatory = $true, Position = 0)][string]$Path) {
    $newPath = [string[]]@(Get-PathVariable | Where-Object { ![string]::IsNullOrWhitespace($_) -and ($_ -ne $Path) })
    Set-PathVariable -PathValues $newPath
}

# Put dotfiles bin on the path. Also put functions on the path since unlike ZSH, PowerShell
# runs scripts in the same shell instance (so there's no need to load the files as though they
# were functions
Add-PathVariable "$DotFilesRoot\functions"
Add-PathVariable "$DotFilesRoot\bin"

$DotNetPath = Join-Path "$env:USERPROFILE" ".dotnet\x64"
Add-PathVariable -Prepend $DotNetPath

Add-PathVariable -Prepend "C:\Chocolatey\bin"
Add-PathVariable -Prepend "C:\Tools\bin"