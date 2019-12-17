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