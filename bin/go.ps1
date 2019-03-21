<#
.SYNOPSIS
    Changes directory to a well-known location. Usually a code repo.
.PARAMETER Target
    The target to change to. Supported formats:
        * [owner]/[repo] - A local working copy of a code repo.
#>
param([string]$Target)

if ($Target -eq "back") {
    Pop-Location -StackName "go"
}
elseif ($Target -eq "up") {
    Push-Location -StackName "go" ..
}
elseif ($Target -eq "code") {
    Push-Location -StackName "go" Code:\
}
elseif ($Target -eq "dotfiles") {
    Push-Location -StackName "go" Dotfiles:\
}
elseif ($Target -match "(?<owner>[a-zA-Z0-9-_]+)/(?<repo>[a-zA-Z0-9-_]+)") {
    $Path = Join-Path (Join-Path Code:\ $matches["owner"]) $matches["repo"]
    if (Test-Path $Path) {
        Push-Location -StackName "go" $Path
    }
    else {
        throw "Path '$Path' does not exist!"
    }
}