$NvimConfigRoot = Join-Path $env:LOCALAPPDATA "nvim"
$NvimDotfilesRoot = Join-Path $DotFiles_Root "nvim"

$Global:DotFiles_LinksToCreate += @(@{
        "Link"   = $NvimConfigRoot
        "Target" = $NvimDotfilesRoot
    })
