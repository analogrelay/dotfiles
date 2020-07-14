function New-Link(
    [Parameter(Mandatory = $true)][string]$Target,
    [Parameter(Mandatory = $true)][string]$Destination) {

    if (Test-Path $Destination) {
        Remove-Item $Destination
    }

    $Parent = Split-Path -Parent $Destination
    if (!(Test-Path $Parent)) {
        New-Item -Type Directory $Parent | Out-Null
    }

    New-Item -Type SymbolicLink -Path $Destination -Value (Convert-Path $Target) -Force | Out-Null
}

function Confirm(
    [Parameter(Mandatory = $true)][string]$Title,
    [Parameter(Mandatory = $true)][string]$Message) {

    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

    $decision = $Host.UI.PromptForChoice($Title, $Message, $choices, 1)
    if ($decision -eq 0) {
        $true
    }
    else {
        $false
    }
}

function Test-Command([Parameter(Mandatory = $true, Position = 0)][string]$Command) {
    [bool](Get-Command "$Command*" | Where-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -eq "$Command" })
}

function Doing($action) {
    Write-Host -ForegroundColor Green $action
}