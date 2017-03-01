$CodeUserSettingsRoot = Join-Path (Join-Path $env:APPDATA "Code") "User"
$CodeDotfilesRoot = Join-Path $DotFiles_Root "vscode"

$Global:DotFiles_LinksToCreate += @(@{
	"Link" = Join-Path $CodeUserSettingsRoot "settings.json"
	"Target" = Join-Path $CodeDotfilesRoot "settings.json"
})
$Global:DotFiles_LinksToCreate += @(@{
	"Link" = Join-Path $CodeUserSettingsRoot "keybindings.json"
	"Target" = Join-Path $CodeDotfilesRoot "keybindings.json"
})
