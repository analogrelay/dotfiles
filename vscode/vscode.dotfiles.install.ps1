$Link = Join-Path (Join-Path (Join-Path $env:APPDATA "Code") "User") "settings.json"
$Target = Join-Path (Join-Path $DotFiles_Root "vscode") "settings.json"
$Global:DotFiles_LinksToCreate += @(@{
	"Link"=$Link
	"Target"=$Target
})