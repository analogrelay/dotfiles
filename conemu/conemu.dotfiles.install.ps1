$Link = Join-Path $env:APPDATA "ConEmu.xml"
$Target = Join-Path (Join-Path $DotFiles_Root "conemu") "ConEmu.xml"
$Global:DotFiles_LinksToCreate += @(@{
	"Link"=$Link
	"Target"=$Target
})