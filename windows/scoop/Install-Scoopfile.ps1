param([string]$Scoopfile = "$PSScriptRoot\Scoopfile")

$Rules = & "$PSScriptRoot\Get-Scoopfile.ps1" $Scoopfile

$Rules | ForEach-Object {
    if($_.Test -and $_.Test.Invoke($_)) {
        Write-Host -ForegroundColor Green "Using $($_.Name) ..."
    } else {
        $message = $_.InstallMessage
        if(!$message) {
            $message = "Installing $($_.Name) ..."
        }
        Write-Host -ForegroundColor Magenta $message
        $_.Install.Invoke($_)
    }
}