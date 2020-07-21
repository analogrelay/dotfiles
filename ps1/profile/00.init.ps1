$env:HOME = [Environment]::GetFolderPath("UserProfile")
$Ps1Path = Split-Path -Parent $PSScriptRoot
$global:DotFilesRoot = Split-Path -Parent $Ps1Path
$global:DotFilesBinPath = Join-Path $DotFilesRoot "bin"

if($PSVersionTable.PSEdition -eq "Desktop") {
    $global:IsWindows = $true
    $global:IsMacOS = $false
    $global:IsLinux = $false
    $global:IsCoreCLR = $false
}