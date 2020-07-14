# Modify this file to your hearts content!

$DotFilesRepo = "git@github.com:anurse/dotfiles.git"
$DotFilesInstallScripts = @()

if ($PSVersionTable.Platform -eq "Win32NT") {
    $DotFilesInstallScripts += @(
        "./windows/install.ps1",
        "./windows/winterm/install.ps1"
    )
}

# Install Scripts to be run (paths relative to the dotfiles root)
$DotFilesInstallScripts += @(
    "./ps1/install.ps1",
    "./git/install.ps1",
    "./vscode/install.ps1"
)

# Core-only modules
$DotFilesPowerShellModules = @(
    "posh-git",
    "oh-my-posh",
    "PS-Tokens"
)

if ($IsWindows) {
    $DotFilesPowerShellModules += @(
        "VSSetup"
    )
}