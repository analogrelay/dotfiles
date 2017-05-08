param([string]$Url)
if (!$Url) {
    Write-Error "Usage: vimstall [url]"
    return
}

$LastSlashIndex = $Url.LastIndexOf("/");
$Name = $Url.Substring($LastSlashIndex + 1);

pushd $DotFilesRoot
try {
    git submodule add $url vim.symlink/bundle/$Name
} finally {
    popd
}
