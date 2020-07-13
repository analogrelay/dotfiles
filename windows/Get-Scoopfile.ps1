Import-Module "$PSScriptRoot/Scoopfile-Sdk.psm1"
. "$PSScriptRoot/scoopfile.ps1"
$Defs = Get-Definitions
Remove-Module "Scoopfile-Sdk"

$Defs