$CodeDir = Join-Path $env:USERPROFILE "Code"
if(!(Test-Path $CodeDir)) {
    mkdir $CodeDir | Out-Null
}

$Link = Join-Path $CodeDir ".editorconfig"
$Target = Join-Path (Join-Path $DotFiles_Root "editorconfig") "editorconfig.conf"
$Global:DotFiles_LinksToCreate += @(@{
	"Link"=$Link
	"Target"=$Target
})
