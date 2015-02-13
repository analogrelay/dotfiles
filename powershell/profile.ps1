$DotFilesRoot = Convert-Path (Split-Path -Parent $PSScriptRoot)

function TwoLevelRecursiveDir($filter) {
    dir $DotFilesRoot | ForEach-Object {
        if($_.Name -like $filter) {
            $_
        }
        if($_.PSIsContainer) {
            dir $_.FullName -filter $filter
        }
    }~
}
TwoLevelRecursiveDir "*.profile.ps1" | foreach {
	. $_.FullName
}