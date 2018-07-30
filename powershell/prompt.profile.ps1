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

$StatusExcludedRepositories = "aspnet\Universe"

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

    $Branch = git rev-parse --abbrev-ref HEAD
    if($LASTEXITCODE -eq 0) {
        if ((git config gitprompt.disablestatus) -eq "1") {
            NextSegment Yellow Black
            WriteSegment " $BranchSymbol $Branch "
        }
        else {
            $Status = git status --porcelain
            if ([string]::IsNullOrWhiteSpace($Status)) {
                NextSegment Green Black
                WriteSegment " $BranchSymbol $Branch "
            } else {
                NextSegment Red Black
                WriteSegment " $BranchSymbol $Branch "
            }
        }
    }

    NextSegment Black

    Write-Host

    $LASTEXITCODE = $realLASTEXITCODE
    $Host.UI.RawUI.WindowTitle = $pwd
    return "ps1$PromptSymbol "
}
