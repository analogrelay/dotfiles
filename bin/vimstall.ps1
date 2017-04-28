param([string]$Url)
if (!$Url) {
    Write-Error "Usage: vimstall [url] [branch]"
    return
}

$name=(New-Object Uri $Url).Segments[-1]

pushd $DotFilesRoot
try {
    git submodule add $url vim.symlink/bundle/$name
} finally {
    popd
}
