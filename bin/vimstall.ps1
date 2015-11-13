param([string]$Url, [string]$Branch)
if (!$Url) {
    Write-Error "Usage: vimstall [url] [branch]"
    return
}

$name=(New-Object Uri $Url).Segments[-1]

if (!$Branch) {
    $Branch = "master"
}

pushd $DotFilesRoot
try {
    git subtree add --prefix vim.symlink/bundle/$name $url $branch --squash
} finally {
    popd
}
