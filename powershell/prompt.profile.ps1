function prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    if($GitPromptSettings.DefaultForegroundColor) {
        $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    }

    Write-Host $pwd -nonewline -ForegroundColor ([ConsoleColor]::Yellow)

    # If we have kvm, use it to determine the active KRE
    if(Get-Command kvm -ErrorAction SilentlyContinue) {
        $activeKre = kvm list -passthru | where { $_.Active }
        if($activeKre) {
            Write-Host " [" -nonewline -ForegroundColor ([ConsoleColor]::Yellow)
            Write-Host "kre-$($activeKre.Runtime)-win-$($activeKre.Architecture).$($activeKre.Version)" -nonewline -ForegroundColor ([ConsoleColor]::Cyan)
            Write-Host "]" -nonewline -ForegroundColor ([ConsoleColor]::Yellow)
        }
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
