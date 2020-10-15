# Modify this file to your hearts content!

$DotFilesRepo = "git@github.com:anurse/dotfiles.git"
$DotFilesInstallScripts = @()

if($PSVersionTable.PSEdition -eq "Desktop") {
    $global:IsWindows = $true
    $global:IsMacOS = $false
    $global:IsLinux = $false
    $global:IsCoreCLR = $false
}

if ($IsWindows) {
    $DotFilesInstallScripts += @(
        "./windows/install.ps1",
        "./windows/winterm/install.ps1"
    )
}

# Install Scripts to be run (paths relative to the dotfiles root)
$DotFilesInstallScripts += @(
    "./ps1/install.ps1",
    "./git/install.ps1"
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