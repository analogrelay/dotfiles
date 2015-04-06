param(
    [string]$DotFilesRoot,
    [string]$UserProfile,
    [switch]$Reset)

$Global:DotFiles_Root = $DotFilesRoot

if(!$Global:DotFiles_Root) {
    $Global:DotFiles_Root = Convert-Path (Split-Path -Parent $PSScriptRoot)
}
if(!$UserProfile) {
    $UserProfile = $env:USERPROFILE
}

$env:HOME = $env:USERPROFILE

$gitroot = Join-Path $DotFiles_Root "git"
$gitconfig = Join-Path $gitroot  "gitconfig"
$gitconfig_templ = Join-Path $gitroot "gitconfig.template"

if($Reset -and (Test-Path $gitconfig)) {
    Remove-Item $gitconfig
}

if(!(Test-Path $gitconfig)) {
    Write-Host "Setting up your git config"

    $authorName = Read-Host " - What is your github author name?"
    $authorEmail = Read-Host " - What is your github author email?"

    $newConfig = [IO.File]::ReadAllText($gitconfig_templ)
    $newConfig = $newConfig.Replace("AUTHORNAME", $authorName)
    $newConfig = $newConfig.Replace("AUTHOREMAIL", $authorEmail)
    $newConfig = $newConfig.Replace("GIT_CREDENTIAL_HELPER", "winstore")
    $newConfig = $newConfig.Replace("EDITOR", "GitPad")

    [IO.File]::WriteAllText($gitconfig, $newConfig)
}

$Global:DotFiles_LinksToCreate = @()

function TwoLevelRecursiveDir($filter) {
    dir $DotFiles_Root | ForEach-Object {
        if($_.Name -like $filter) {
            $_
        }
        if($_.PSIsContainer) {
            dir $_.FullName -filter $filter
        }
    }
}

TwoLevelRecursiveDir "*.copy" | foreach {
    $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
    $dest = Join-Path $UserProfile ".$name"
    Write-Host "Copying $($_.Name) to profile as .$name"
    Copy-Item $_.FullName $dest
}

TwoLevelRecursiveDir "*.symlink" | foreach {
    $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
    $link = Join-Path $UserProfile ".$name"
    if(!(Test-Path $link)) {
        $Global:DotFiles_LinksToCreate += @(@{
            "Link"=$link;
            "Target"=$_.FullName
        })
    }
}

# Run install scripts
TwoLevelRecursiveDir "*.dotfiles.install.ps1" | foreach {
    & $_.FullName
}

if($DotFiles_LinksToCreate.Length -gt 0) {
    Write-Host "Need to create $($DotFiles_LinksToCreate.Length) links. Elevating..."

    $script = "`$links=@("
    $first = $true;
    $DotFiles_LinksToCreate | foreach {
        if($first) {
            $first = $false
        } else {
            $script += ","
        }
        $script += "@{`"Link`"=`"$($_["Link"])`";`"Target`"=`"$($_["Target"])`"}"
    }
    $script += ");& $PSScriptRoot\mklinks.ps1"
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($script))

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell"
    $psi.Arguments = "-NoProfile -NoLogo -EncodedCommand $encoded"
    $psi.Verb = "runas"
    $p = [System.Diagnostics.Process]::Start($psi)
    $p.WaitForExit()
} else {
    Write-Host "No links to create!"
}

# Write the boot profile script
$profileDir = Split-Path -Parent $Profile
if(!(Test-Path $profileDir)) {
    mkdir $profileDir | Out-Null
}
". $DotFiles_Root\powershell\profile.ps1" > $profile

# Update submodules
pushd $DotFiles_Root
git submodule update --recursive --init
popd