# Modify this file to your hearts content!


# Install Scripts to be run (paths relative to the dotfiles root)
$DotFilesInstallScripts = @(
    (Join-Path "ps1" "install.ps1"),
    (Join-Path "git" "install.ps1"),
    (Join-Path "conemu" "install.ps1"),
    (Join-Path "fonts" "install.ps1")
    (Join-Path "vscode" "install.ps1")
)

# Core-only modules
$DotFilesPowerShellCoreModules = @(
    "PS-GitHub"
)
$DotFilesPowerShellModules = @(
    "posh-git",
    "oh-my-posh",
    "PS-Tokens",
    "VSSetup"
)

if ($PSVersionTable.PSEdition -eq "Core") {
    $DotFilesPowerShellModules += $DotFilesPowerShellCoreModules
}