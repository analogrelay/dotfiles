$WindowsSymbol = [char]0xf17a;
$LinuxSymbol = [char]0xf17c;
$AppleSymbol = [char]0xf179;
$DirSymbol = [char]0xf07b;
$BranchSymbol = [char]0xe0a0;
$ArrowSymbol = [char]0xe0b0;
$PromptSymbol = [char]0x203a;

$OsSymbol = $WindowsSymbol

Set-PSReadlineOption -TokenKind Parameter -ForegroundColor Cyan

function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host -ForegroundColor Black -BackgroundColor Cyan " $OsSymbol $([Environment]::MachineName) " -NoNewLine
    Write-Host -ForegroundColor Cyan -BackgroundColor Yellow $ArrowSymbol -NoNewLine

    Write-Host -ForegroundColor Black -BackgroundColor Yellow " $DirSymbol $(Get-Location) " -NoNewLine

    git status -s 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $Status = git status --porcelain
        $Branch = git rev-parse --abbrev-ref HEAD
        if ([string]::IsNullOrWhiteSpace($Status)) {
            Write-Host -ForegroundColor Yellow -BackgroundColor Green $ArrowSymbol -NoNewLine
            Write-Host -BackgroundColor Green " $BranchSymbol $Branch " -NoNewLine
            Write-Host -ForegroundColor Green -BackgroundColor Black $ArrowSymbol -NoNewLine
        } else {
            Write-Host -ForegroundColor Yellow -BackgroundColor Red $ArrowSymbol -NoNewLine
            Write-Host -BackgroundColor Red " $BranchSymbol $Branch " -NoNewLine
            Write-Host -ForegroundColor Red -BackgroundColor Black $ArrowSymbol -NoNewLine
        }
    }
    else {
        Write-Host -ForegroundColor Yellow -BackgroundColor Black $ArrowSymbol -NoNewLine
    }

    Write-Host

    $LASTEXITCODE = $realLASTEXITCODE
    $Host.UI.RawUI.WindowTitle = $pwd
    return "ps1$PromptSymbol "
}
