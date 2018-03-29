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
    Runs the specified script block in the dotfiles folder
#>
function dotfiles-exec {
    param(
        [Parameter(Mandatory=$false,Position=0)][ScriptBlock]$Command
    )

    Push-Location $DotFilesRoot
    try {
        & $Command
    } finally {
        Pop-Location
    }
}

<#
.SYNOPSIS
    Show git status for the dotfiles repo
#>
function dotfiles-status {
    dotfiles-exec { git status }
}

<#
.SYNOPSIS
    Commit recent changes to the dotfiles repo.
#>
function dotfiles-commit {
    param(
        [Alias("m")][Parameter(Mandatory=$true)][string]$Message
    )

    dotfiles-exec { 
        # To print out the list of added files
        git add -An

        git add -A
        git commit -am"$Message"
    }
}

<#
.SYNOPSIS
    Sync changes with the origin repo
#>
function dotfiles-sync {
    dotfiles-exec {
        git pull --rebase origin master
        git push origin master
    }
}

<#
.SYNOPSIS
    Launch Visual Studio Code (Insiders build, if installed) in the dotfiles folder
#>
function dotfiles-edit {
    $cmd = "code-insiders"
    if(!(Get-Command $cmd -ErrorAction SilentlyContinue)) {
        $cmd = "code"
        if(!(Get-Command $cmd -ErrorAction SilentlyContinue)) {
            throw "Could not find 'code' or 'code-insiders' commands"
        }
    }

    dotfiles-exec {
        & "$cmd" .
    }
}

$FnPath = "function:\dotfiles-$Command"
if(Test-Path $FnPath) {
    & (Get-Item $FnPath) @Arguments
} else {
    throw "Unknown command '$Command' use 'dotfiles commands' to list available commands"
}