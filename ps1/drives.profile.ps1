# Setup drives
New-PSDrive -Name Home -Root "$env:USERPROFILE" -PSProvider FileSystem | Out-Null

if ($DotFilesRoot) {
    New-PSDrive -Name DotFiles -Root $DotFilesRoot -PSProvider FileSystem | Out-Null
}

if (Test-Windows) {
    $CodeDir = "C:\Code"
    if (!(Test-Path $CodeDir)) {
        $ProfileCodeDir = Join-Path $env:USERPROFILE "Code"
        if (Test-Path $ProfileCodeDir) {
            Write-Warning "Code directory is in $ProfileCodeDir. This is deprecated as it has long path problems on Windows."
            $CodeDir = $ProfileCodeDir
        } else {
            Write-Host "Creating code directory: $CodeDir"
            mkdir $CodeDir | Out-Null
        }
    }
    New-PSDrive -Name Code -Root $CodeDir -PSProvider FileSystem | Out-Null
}

if ($env:ACQYRE_LIBRARY -and (Test-Path "$env:ACQYRE_LIBRARY")) {
    New-PSDrive -Name Library -Root "$env:ACQYRE_LIBRARY" -PSProvider FileSystem | Out-Null
}

New-PSDrive -Name Desktop -Root ([Environment]::GetFolderPath("Desktop")) -PSProvider FileSystem | Out-Null
