param(
    [string]$DotFilesRoot,
    [string]$UserProfile)

if(!$DotFilesRoot) {
    $DotFilesRoot = Convert-Path (Split-Path -Parent $PSScriptRoot)
}
if(!$UserProfile) {
    $UserProfile = $env:USERPROFILE
}

$env:HOME = $env:USERPROFILE

$linksToCreate = @()

dir $DotFilesRoot -fil "*.copy" | foreach {
    $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
    $dest = Join-Path $UserProfile $name
    Write-Host "Copying $($_.Name) to profile as $name"
    Copy-Item $_.FullName $dest
}

dir $DotFilesRoot -fil "*.symlink" | foreach {
    $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
    $link = Join-Path $UserProfile $name
    if(!(Test-Path $link)) {
       $linksToCreate += @(@{
            "Link"=$link;
            "Target"=$_.FullName
        })
    }
}

if($linksToCreate.Length -gt 0) {
    Write-Host "Need to create $($linksToCreate.Length) links. Elevating..."

    $script = "`$links=@("
    $linksToCreate | foreach {
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