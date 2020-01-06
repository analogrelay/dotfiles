function Test-Command($CommandName) {
    # Calling Get-Command, even with ErrorAction SilentlyContinue, spams
    # $error with errors. This avoids that.
    !!(Get-Command "$CommandName*" | 
        Where-Object {
            [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -eq $CommandName
        })
}

if(!(Test-Command colortool)) {
	scoop install colortool
}

$ColorProfile = Convert-Path (Join-Path $PSScriptRoot "vibrantcode.itermcolors")
colortool -b $ColorProfile

Write-Host -ForegroundColor Green "Launching Windows Store to recommend installation of Windows Terminal"
Start-Process "ms-windows-store://pdp/?ProductId=9N0DX20HK701"