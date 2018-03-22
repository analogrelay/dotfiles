$ResharperSettingsPath = "$env:APPDATA\JetBrains\Shared\vAny\GlobalSettingsStorage.DotSettings"
$DotFilesResharperSettingsRoot = Join-Path $DotFiles_Root "jetbrains"

$Global:DotFiles_LinksToCreate += @(@{
    "Link" = $ResharperSettingsPath
    "Target" = Join-Path $DotFilesResharperSettingsRoot "GlobalSettingsStorage.DotSettings"
})