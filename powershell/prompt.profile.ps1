$WindowsSymbol = [char]0xf17a;
$LinuxSymbol = [char]0xf17c;
$AppleSymbol = [char]0xf179;
$DirSymbol = [char]0xf07b;
$BranchSymbol = [char]0xe725;
$ArrowSymbol = [char]0xe0b0;
$PromptSymbol = [char]0x203a;
$DotNetSymbol = [char]0xe70c;
$ClockSymbol = [char]0xf017;

$OsSymbol = $WindowsSymbol

Set-PSReadlineOption -TokenKind Parameter -ForegroundColor Cyan

function GetLocationWithSubstitution() {
    $loc = Get-Location
    $loc.Path.Replace("$env:USERPROFILE", "~")
}

function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    $CurrentFg = [System.ConsoleColor]::Black;
    $CurrentBg = [System.ConsoleColor]::White;

    function NextSegment([System.ConsoleColor]$NextBg, [System.ConsoleColor]$NextFg) {
        Write-Host -ForegroundColor $CurrentBg -BackgroundColor $NextBg $ArrowSymbol -NoNewLine
        Set-Variable -Scope 1 -Name CurrentBg -Value $NextBg
        Set-Variable -Scope 1 -Name CurrentFg -Value $NextFg
    }

    function WriteSegment([string]$Str) {
        Write-Host -ForegroundColor $CurrentFg -BackgroundColor $CurrentBg $Str -NoNewLine
    }

    WriteSegment " $ClockSymbol $([DateTime]::Now.ToString("HH:mm")) "
    NextSegment Cyan Black

    WriteSegment " $OsSymbol $([Environment]::MachineName) "
    NextSegment Yellow Black

    WriteSegment " $DirSymbol $(GetLocationWithSubstitution) "

    if (Get-Command -ErrorAction SilentlyContinue dotnet) {
        NextSegment DarkBlue White
        WriteSegment " $DotNetSymbol $(dotnet --version) "
    }

    git status -s 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $Status = git status --porcelain
        $Branch = git rev-parse --abbrev-ref HEAD
        if ([string]::IsNullOrWhiteSpace($Status)) {
            NextSegment Green Black
            WriteSegment " $BranchSymbol $Branch "
        }
        else {
            NextSegment Red Black
            WriteSegment " $BranchSymbol $Branch "
        }
    }

    NextSegment Black

    Write-Host

    $LASTEXITCODE = $realLASTEXITCODE
    $Host.UI.RawUI.WindowTitle = $pwd
    return "ps1$PromptSymbol "
}
