param($Url)

$Name = ([uri]$Url).Segments[-1]


pushd $DotFilesRoot
try {
    git submodule add $Url "vim.symlink/bundle/$Name"
} finally {
    popd
}
