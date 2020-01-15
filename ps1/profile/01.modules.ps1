# Configure Module Path
$LocalModulePath = Join-Path (Split-Path -Parent $PSScriptRoot) "modules"
$env:PSModulePath = "$(Convert-Path $LocalModulePath)$([IO.Path]::PathSeparator)$env:PSModulePath"

# Load Posh-Git and Oh-My-Posh
$DotFilesPowerShellModules | ForEach-Object {
    if (!(Get-Module -ListAvailable $_)) {
        Write-Host "Installing module '$_' ..."
        Install-Module $_ -Scope CurrentUser -AllowPrerelease
    }
    Import-Module $_
}