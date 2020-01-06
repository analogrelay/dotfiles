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
        # Remove it and prepend it. The request to "add" is basically a request to move it forward
        Remove-PathVariable $Path
        $Prepend = $true
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

# Enlighten the PATH
Add-PathVariable "$DotFilesRoot\bin"

# Scoop *ALWAYS* wins, even when there's a machine-level PATH value ahead.
$ScoopDir = Join-Path $env:USERPROFILE "scoop\shims"
Add-PathVariable $ScoopDir -Prepend