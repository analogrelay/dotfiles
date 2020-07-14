if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

# Install to both Code and Code - Insiders
$CodeVersions = @("Code", "Code - Insiders")

$CodeDotfilesRoot = Join-Path $DotFilesRoot "vscode"
$DotFilesSettings = Join-Path $CodeDotfilesRoot "settings.json"
$DotFilesKeybinds = Join-Path $CodeDotfilesRoot "keybindings.json"

$CodeVersions | ForEach-Object {
    Write-Host "Installing Settings symlinks for $_"
    $UserSettingsRoot = Join-Path (Join-Path $env:APPDATA $_) "User"

    if (!(Test-Path $UserSettingsRoot)) {
        New-Item -Type Directory $UserSettingsRoot | Out-Null
    }

    $SettingsFile = Join-Path $UserSettingsRoot "settings.json"
    $KeybindingsFile = Join-Path $UserSettingsRoot "keybindings.json"

    # Create Symlinks
    New-Link -Target $DotFilesSettings -Destination $SettingsFile
    New-Link -Target $DotFilesKeybinds -Destination $KeybindingsFile
}