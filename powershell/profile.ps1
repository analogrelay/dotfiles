$Global:DotFilesRoot = Convert-Path (Split-Path -Parent $PSScriptRoot)

# Locate code root
$DefaultCodeRoot = Join-Path $env:USERPROFILE "Code"
if ($env:PROJECTS) {
    $CodeRoot = $env:PROJECTS
}
elseif (Test-Path $DefaultCodeRoot) {
    $CodeRoot = $DefaultCodeRoot
    $env:PROJECTS = $CodeRoot
}

# Add the modules from dotfiles to the module path
$env:PSModulePath = "$DotFilesRoot\powershell\modules;$env:PSModulePath"

# Install (if needed) and import Modules
$Modules = @(
    "posh-git")
$Modules | ForEach-Object {
    if (!(Get-Module -ListAvailable $_)) {
        Write-Host "Installing Module $_ ..."
        Install-Module $_ -Scope CurrentUser
    }
    Import-Module $_
}

# Load all modules, unless they are disabled
dir "$DotFilesRoot\powershell\modules" | Where-Object { $_.PSIsContainer } | ForEach-Object {
    if (!(Test-Path "$DotFilesRoot\powershell\modules\$($_.Name).disabled")) {
        Import-Module ($_.Name)
    }
}

function gitconfig! {
    & "$DotFilesRoot\sys\gitconfig.ps1"
}

function TwoLevelRecursiveDir($filter) {
    dir $DotFilesRoot | ForEach-Object {
        if ($_.Name -like $filter) {
            $_
        }
        if ($_.PSIsContainer) {
            dir $_.FullName -filter $filter
        }
    }
}

function Profile! {
    . "$PSScriptRoot\profile.ps1"
}

function UpdateDotFiles {
    pushd Dotfiles:\; git pull origin master; popd
    Profile!
}

TwoLevelRecursiveDir "*.profile.ps1" | foreach {
    . $_.FullName
}

try {
    [Console]::CursorSize = 25
}
catch {}
