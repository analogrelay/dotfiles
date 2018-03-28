<#
.SYNOPSIS
    Commands to help manage the dotfiles
.PARAMETER Command
    The command to execute
.PARAMETER Arguments
    Arguments to pass to the command
.DESCRIPTION
    Use the 'dotfiles help' subcommand to get help on a specific command. Use 'dotfiles commands' to list available commands.
#>

param(
    [Parameter(Mandatory=$false, Position=0)][string]$Command,
    [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)][object[]]$Arguments
)

$DotFilesRoot = Split-Path -Parent $PSScriptRoot

<#
.SYNOPSIS
    Gets the list of available commands
#>
function dotfiles-commands {
    Get-ChildItem "function:\dotfiles-*" | ForEach-Object {
        $Synopsis = (Get-Help $_).Synopsis
        New-Object PSCustomObject -Property @{
            "Name" = $_.Name.Replace("dotfiles-", "");
            "Synopsis" = $Synopsis
        }
    } | Format-Table Name,Synopsis
}

<#
.SYNOPSIS
    Gets help for a particular command
.PARAMETER Command
    An, optional, command to get help for
#>
function dotfiles-help {
    param(
        [Parameter(Mandatory=$false)][string]$Command)

    if($Command) {
        Get-Help dotfiles-$Command
    } else {
        Get-Help $MyScript
    }
}

<#
.SYNOPSIS
    Runs the specified git command in the dotfiles folder
#>
function dotfiles-git {
    param(
        [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)][object[]]$Arguments
    )

    Push-Location $DotFilesRoot
    try {
        & git @Arguments
    } finally {
        Pop-Location
    }
}

$FnPath = "function:\dotfiles-$Command"
if(Test-Path $FnPath) {
    & (Get-Item $FnPath) @Arguments
} else {
    throw "Unknown command '$Command' use 'dotfiles commands' to list available commands"
}