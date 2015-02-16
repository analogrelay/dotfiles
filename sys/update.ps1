param(
    [string]$DotFilesRoot,
    [string]$UserProfile,
    [switch]$Reset)

$Global:DotFiles_Root = $DotFilesRoot

if(!$Global:DotFiles_Root) {
    $Global:DotFiles_Root = Convert-Path (Split-Path -Parent $PSScriptRoot)
}
if(!$UserProfile) {
    $UserProfile = $env:USERPROFILE
}

pushd $DotFiles_Root
try {
	git submodule update --init
} finally {
	popd
}