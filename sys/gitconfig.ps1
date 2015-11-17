param($DotFilesRoot)

if(!$DotFilesRoot) {
    $DotFilesRoot = Convert-Path (Split-Path -Parent $PSScriptRoot)
}

$gitroot = Join-Path $DotFilesRoot "git"
$gitconfig = Join-Path $gitroot  "gitconfig"
$gitconfig_templ = Join-Path $gitroot "gitconfig.template"

Write-Host "Setting up your git config"

$authorName = Read-Host " - What is your github author name?"
$authorEmail = Read-Host " - What is your github author email?"

$newConfig = [IO.File]::ReadAllText($gitconfig_templ)
$newConfig = $newConfig.Replace("AUTHORNAME", $authorName)
$newConfig = $newConfig.Replace("AUTHOREMAIL", $authorEmail)
$newConfig = $newConfig.Replace("GIT_CREDENTIAL_HELPER", "wincred")
$newConfig = $newConfig.Replace("EDITOR", "gvim")

[IO.File]::WriteAllText($gitconfig, $newConfig)
