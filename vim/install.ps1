if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }


$VimRcPath = Join-Path $env:HOME ".vimrc"
$VimPath = Join-Path $env:HOME ".vim"

$VimTarget = Join-Path $DotFilesRoot "vim"
$VimRcTarget = Join-Path $VimTarget "vimrc.vim"

New-Item -Force -ItemType SymbolicLink -Path $VimRcPath -Value $VimRcTarget | Out-Null

if(!(Test-Path $VimPath)) {
    New-Item -Force -ItemType Junction -Path $VimPath -Value $VimTarget | Out-Null
}