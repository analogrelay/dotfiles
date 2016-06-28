function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    if($GitPromptSettings.DefaultForegroundColor) {
        $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    }

    Write-Host $pwd -nonewline -ForegroundColor ([ConsoleColor]::Yellow)

    if(Get-Command dotnet -ErrorAction SilentlyContinue) {
        try {
            $dotnetVersion = (dotnet --version).Trim()
        } catch {
            $dotnetVersion = "<<error>>"
        }
    }

    if($dotnetVersion) {
        Write-Host " (dotnet:$dotnetVersion)" -nonewline -ForegroundColor ([ConsoleColor]::Yellow)
    }

    if(Get-Command Write-VcsStatus -ErrorAction SilentlyContinue) {
        Write-VcsStatus
    }

    Write-Host
    Write-Host "ps1 #" -nonewline -ForegroundColor ([ConsoleColor]::Green)

    $LASTEXITCODE = $realLASTEXITCODE
    $Host.UI.RawUI.WindowTitle = $pwd
    return " "
}
