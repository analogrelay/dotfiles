<#
.SYNOPSIS
    Changes directory to a well-known location. Usually a code repo.
.PARAMETER Target
    The target to change to. Supported formats:
        * [owner]/[repo] - A local working copy of a code repo.
#>
param([string]$Target)

if ($Target -eq "back") {
    Pop-Location -StackName "goto"
}
elseif ($Target -eq "up") {
    Push-Location -StackName "goto" ..
}
elseif ($Target -eq "code") {
    Push-Location -StackName "goto" $env:CODE_ROOT
}
elseif ($Target -eq "dotfiles") {
    Push-Location -StackName "goto" $DotFilesRoot
}
elseif ($Target -eq "desktop") {
    Push-Location -StackName "goto" ([System.Environment]::GetFolderPath("Desktop"))
}
elseif ($Target -match "(?<owner>[a-zA-Z0-9-_\.]+)/(?<repo>[a-zA-Z0-9-_\.]+)") {
    $Path = Join-Path (Join-Path $env:CODE_ROOT $matches["owner"]) $matches["repo"]
    if (Test-Path $Path) {
        Push-Location -StackName "goto" $Path
    }
    elseif (Confirm "Clone?" "Repo '$Target' not cloned. Clone it?") {
        clone $Target
    }
    else {
        Write-Host "Path '$Path' does not exist!"
    }
}
else {
    Write-Host "Unknown target: $Target"
    Write-Host "Supported Targets:"
    Write-Host "* back"
    Write-Host "* up"
    Write-Host "* code"
    Write-Host "* dotfiles"
    Write-Host "* desktop"
    Write-Host "* [owner]/[repo]"
}