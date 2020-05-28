#requires -Version 2 -Modules posh-git
# Based heavily on Paradox theme

$global:Profile_PromptTimings = @{ }
function TimeBlock($name, [scriptblock]$block) {
    $blockOutput = $null
    $duration = Measure-Command {
        $blockOutput = & $block
    }
    $Profile_PromptTimings[$name] = $duration
    $blockOutput
}

. "$PSScriptRoot\..\utils.ps1"

if ($PsVersionTable.Platform -eq "Win32NT") {
    $machinePath = Join-Path $env:ProgramFiles "dotnet\dotnet.exe"
    $userLocalPath = Join-Path $env:USERPROFILE ".dotnet\x64\dotnet.exe"
}
else {
    $machinePath = "/usr/bin/dotnet"
    $userLocalPath = "$env:HOME/.dotnet/dotnet"
}

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    TimeBlock "prompt" {
        $OsSymbol = TimeBlock "os" {
            if ($PsVersionTable.Platform -eq "Unix") {
                $uname = uname
                if ($uname -eq "Linux") {
                    if ((uname -r) -match ".*Microsoft$") {
                        "$($sl.PromptSymbols.LinuxSymbol) (on $($sl.PromptSymbols.WindowsSymbol))"
                    }
                    else {
                        $sl.PromptSymbols.LinuxSymbol
                    }
                }
                elseif ($uname -eq "Darwin") {
                    $sl.PromptSymbols.AppleSymbol
                }
            }
            else {
                $sl.PromptSymbols.WindowsSymbol
            }
        }

        # Check where dotnet.exe is
        $dotnetHive = TimeBlock "dotnet-hive" {
            if (Test-Command dotnet) {
                $dotnetCommand = Get-Command dotnet
                if ($dotnetCommand.Source -eq $machinePath) {
                    "Machine"
                }
                elseif ($dotnetCommand.Source -eq $userLocalPath) {
                    "User"
                }
                elseif ($dotnetCommand.Source.StartsWith($CodeRoot)) {
                    # Repo-local
                    $repoName = Split-Path -Leaf (Split-Path -Parent (Split-Path -Parent $dotnetCommand.Source))
                    "Repo:$repoName"
                }
            }
        }

        $lastColor = $sl.Colors.PromptBackgroundColor
        $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
        
        #check the last command state and indicate if failed
        if ($lastCommandFailed) {
            $prompt += Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
        }
        else {
            $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SucceededCommandSymbol) " -ForegroundColor $sl.Colors.CommandSucceededIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
        }

        #check for elevated prompt
        If (Test-Administrator) {
            $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
        }

        $user = [System.Environment]::UserName
        $computer = [System.Environment]::MachineName
        if (Test-NotDefaultUser($user)) {
            $prompt += Write-Prompt -Object "$user@$computer $OsSymbol " -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
        }

        $lastColor = $sl.Colors.SessionInfoBackgroundColor
        if (Test-Command dotnet) {
            $dotnetVersion = TimeBlock "dotnet-version" { dotnet --version }
            $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $lastColor -BackgroundColor $sl.Colors.DotNetBackgroundColor
            $lastColor = $sl.Colors.DotNetBackgroundColor
            $prompt += Write-Prompt -Object "$($sl.PromptSymbols.DotNetSymbol) $dotnetVersion ($dotnetHive) " -ForegroundColor $sl.Colors.DotNetForegroundColor -BackgroundColor $sl.Colors.DotNetBackgroundColor
        }

        if (Test-Command rustc) {
            $rustVersion = TimeBlock "rustc" { (rustc --version).Split()[1] }
            $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $lastColor -BackgroundColor $sl.Colors.RustBackgroundColor
            $lastColor = $sl.Colors.RustBackgroundColor
            $prompt += Write-Prompt -Object "$($sl.PromptSymbols.RustSymbol) $rustVersion " -ForegroundColor $sl.Colors.RustForegroundColor -BackgroundColor $sl.Colors.RustBackgroundColor
        }

        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $lastColor -BackgroundColor $sl.Colors.PathBackgroundColor
        $lastColor = $sl.Colors.PathBackgroundColor

        # Writes the drive portion
        $path = Get-FullPath -dir $pwd
        $prompt += Write-Prompt -Object "$path " -ForegroundColor $sl.Colors.PathForegroundColor -BackgroundColor $sl.Colors.PathBackgroundColor

        $themeInfo = TimeBlock "git" {
            $status = Get-VCSStatus
            if ($status) {
                Get-VcsInfo -status ($status)
            }
        }
        if ($themeInfo) {
            $lastColor = $themeInfo.BackgroundColor
            $prompt += Write-Prompt -Object $($sl.PromptSymbols.SegmentForwardSymbol) -ForegroundColor $sl.Colors.PathBackgroundColor -BackgroundColor $lastColor
            $prompt += Write-Prompt -Object " $($themeInfo.VcInfo) " -BackgroundColor $lastColor -ForegroundColor $sl.Colors.GitForegroundColor
        }

        # Writes the postfix to the prompt
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor

        $timeStamp = Get-Date -UFormat %R
        $timestamp = "[$timeStamp]"

        $prompt += Set-CursorForRightBlockWrite -textLength ($timestamp.Length + 1)
        $prompt += Write-Prompt $timeStamp -ForegroundColor $sl.Colors.PromptForegroundColor

        $prompt += Set-Newline

        if ($with) {
            $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
        }
        $prompt += Write-Prompt -Object "ps1 $($sl.PromptSymbols.PromptIndicator)" -ForegroundColor [ConsoleColor]::Blue
        $prompt += ' '
        $prompt
    }
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.StartSymbol = ''
$sl.PromptSymbols.PromptIndicator = "$"
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.PromptSymbols.DotNetSymbol = [char]::ConvertFromUtf32(0xE77F)
$sl.PromptSymbols.RustSymbol = [char]::ConvertFromUtf32(0xE7A8)
$sl.PromptSymbols.WindowsSymbol = [char]::ConvertFromUtf32(0xE70F)
$sl.PromptSymbols.LinuxSymbol = [char]::ConvertFromUtf32(0xE712)
$sl.PromptSymbols.AppleSymbol = [char]::ConvertFromUtf32(0xE711)
$sl.PromptSymbols.SucceededCommandSymbol = [char]::ConvertFromUtf32(0x2713)
$sl.PromptSymbols.FailedCommandSymbol = [char]"x"
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitForegroundColor = [ConsoleColor]::Black
$sl.Colors.GitNoLocalChangesAndAheadColor = [ConsoleColor]::Green
$sl.Colors.GitDefaultColor = [ConsoleColor]::Green
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Red
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White
$sl.Colors.DotNetBackgroundColor = [System.ConsoleColor]::DarkBlue
$sl.Colors.DotNetForegroundColor = [System.ConsoleColor]::White
$sl.Colors.CommandSucceededIconForegroundColor = [System.ConsoleColor]::Green
$sl.Colors.PathForegroundColor = [ConsoleColor]::White
$sl.Colors.PathBackgroundColor = [ConsoleColor]::DarkCyan
$sl.Colors.RustForegroundColor = [ConsoleColor]::White
$sl.Colors.RustBackgroundColor = [ConsoleColor]::DarkRed