<#
.SYNOPSIS
    Outputs a boolean indicating if the current OS is Windows
#>

$PSVersionTable.Platform -eq "Win32NT"