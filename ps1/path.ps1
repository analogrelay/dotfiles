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

    $PathSep = [IO.Path]::PathSeparator

    if ($Prepend) {
        $env:PATH = "$Path$PathSep$env:PATH"
    }
    else {
        $env:PATH = "$env:PATH$PathSep$Path"
    }
}

function global:Remove-PathVariable([Parameter(Mandatory = $true, Position = 0)][string]$Path) {
    $newPath = [string[]]@(Get-PathVariable | Where-Object { ![string]::IsNullOrWhitespace($_) -and ($_ -ne $Path) })
    Set-PathVariable -PathValues $newPath
}