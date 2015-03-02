pushd $DotFilesRoot
try {
    git checkout master
    git pull origin master
    git submodule update

    . $DotFilesRoot\sys\start.ps1
} finally {
    popd
}
