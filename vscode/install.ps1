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
    if (Test-Path $SettingsFile) {
        if (!(Confirm "Remove existing settings" "A VS Code settings file already exists in '$SettingsFile'. Remove it?")) {
            throw "User cancelled installation"
        }
        Remove-Item $SettingsFile
    }
    New-Item -Path $SettingsFile -ItemType SymbolicLink -Value $DotFilesSettings | Out-Null

    if (Test-Path $KeybindingsFile) {
        if (!(Confirm "Remove existing keybindings" "A VS Code keybindings file already exists in '$KeybindingsFile'. Remove it?")) {
            throw "User cancelled installation"
        }
        Remove-Item $KeybindingsFile
    }
    New-Item -Path $KeybindingsFile -ItemType SymbolicLink -Value $DotFilesKeybinds | Out-Null
}