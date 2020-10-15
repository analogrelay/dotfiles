param(
    [Parameter(Mandatory = $false)][switch]$WhatIf
)

if(!$IsWindows -and !$WhatIf) {
    throw "Cannot actually install components on non-Windows platforms."
}

if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Scoop..."
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}