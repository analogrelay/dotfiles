# Setup drives
New-PSDrive -Name Home -Root "$env:USERPROFILE" -PSProvider FileSystem | Out-Null

if($DotFilesRoot) {
	New-PSDrive -Name DotFiles -Root $DotFilesRoot -PSProvider FileSystem | Out-Null
}

if(Test-Path "$env:USERPROFILE\Code") {
	New-PSDrive -Name Code -Root "$env:USERPROFILE\Code" -PSProvider FileSystem | Out-Null
}

if($env:ACQYRE_LIBRARY -and (Test-Path "$env:ACQYRE_LIBRARY")) {
    New-PSDrive -Name Library -Root "$env:ACQYRE_LIBRARY" -PSProvider FileSystem | Out-Null
}

New-PSDrive -Name Desktop -Root ([Environment]::GetFolderPath("Desktop")) -PSProvider FileSystem | Out-Null
