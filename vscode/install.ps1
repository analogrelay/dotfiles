if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

# Install to both Code and Code - Insiders
$CodeVersions = @("Code", "Code - Insiders")

$CodeDotfilesRoot = Join-Path (Join-Path $DotFilesRoot "vscode") "user"

$CodeVersions | ForEach-Object {
    Write-Host "Installing Settings junction for $_"
    $UserSettingsRoot = Join-Path (Join-Path $env:APPDATA $_) "User"

    if (Test-Path $UserSettingsRoot) {
        Remove-Item -Recurse -Force $UserSettingsRoot
    }

    # Create Junction
    New-Item -Value $CodeDotfilesRoot -Path $UserSettingsRoot -ItemType SymbolicLink | Out-Null
}