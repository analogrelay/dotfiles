# Disable Console Title on iTerm2
if($env:LC_TERMINAL -eq "iTerm2") {
    $ThemeSettings.Options.ConsoleTitle = $false
}

if (Test-Command starship) {
    Invoke-Expression $(starship init powershell)
}

if($IsCoreCLR) {
    Set-PSReadLineOption -Colors @{
        "Command"            = "`e[94m";
        "Comment"            = "`e[92m";
        "ContinuationPrompt" = "`e[37m";
        "Default"            = "`e[37m";
        "Emphasis"           = "`e[95m";
        "Error"              = "`e[91m";
        "Keyword"            = "`e[91m";
        "Member"             = "`e[97m";
        "Number"             = "`e[97m";
        "Operator"           = "`e[91m";
        "Parameter"          = "`e[37m";
        "Selection"          = "`e[30;47m";
        "String"             = "`e[96m";
        "Type"               = "`e[37m";
        "Variable"           = "`e[92m";
    }
}