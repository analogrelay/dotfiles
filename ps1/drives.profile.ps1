# Setup drives
if ($DotFilesRoot -and (!(Test-Path DotFiles:\))) {
    New-PSDrive -Name DotFiles -Root $DotFilesRoot -PSProvider FileSystem | Out-Null
}

if ($PSVersionTable.Platform -eq "Win32NT") {
    $CodeDir = "C:\Code"
    $ProfileCodeDir = Join-Path $env:USERPROFILE "Code"
    if (!(Test-Path $CodeDir) -and (Test-Path $ProfileCodeDir)) {
        Write-Warning "Code directory is in $ProfileCodeDir. This is deprecated as it has long path problems on Windows."
        $CodeDir = $ProfileCodeDir
    }
}
else {
    $CodeDir = "$env:HOME/code"
}

if (!(Test-Path Code:\)) {
    if (!(Test-Path $CodeDir)) {
        Write-Host "Creating code directory: $CodeDir"
        New-Item -Type Directory $CodeDir | Out-Null
    }
    New-PSDrive -Name Code -Root $CodeDir -PSProvider FileSystem | Out-Null
}
