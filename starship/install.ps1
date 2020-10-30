if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

$ConfigDir = Join-Path $env:HOME ".config"
if(!(Test-Path $ConfigDir)) {
    New-Item -Type Directory $ConfigDir | Out-Null
}

$Link = Join-Path $ConfigDir "starship.toml"

$StarshipRoot = Join-Path $DotFilesRoot "starship"
$Target = Join-Path $StarshipRoot "starship.toml"

New-Item -Force -ItemType SymbolicLink -Path $Link -Value $Target | Out-Null