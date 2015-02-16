$DotFilesRoot = Convert-Path (Split-Path -Parent $PSScriptRoot)

# Restore Library root to front of the PATH
if($env:ACQYRE_LIBRARY) {
    $env:PATH="$env:ACQYRE_LIBRARY\Bin;$env:PATH"
}
$env:PATH="$env:USERPROFILE\.k\bin;$env:PATH"

function TwoLevelRecursiveDir($filter) {
    dir $DotFilesRoot | ForEach-Object {
        if($_.Name -like $filter) {
            $_
        }
        if($_.PSIsContainer) {
            dir $_.FullName -filter $filter
        }
    }
}
TwoLevelRecursiveDir "*.profile.ps1" | foreach {
	. $_.FullName
}