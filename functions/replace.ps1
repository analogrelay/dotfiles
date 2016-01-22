param(
    [Parameter(Mandatory=$true)][string]$FilePattern,
    [Parameter(Mandatory=$true)][string]$SearchString,
    [Parameter(Mandatory=$true)][string]$Replacement,
    [Alias("n")][switch]$DryRun,
    [Alias("f")][switch]$Force,
    [switch]$Regex)

if ($DryRun -and $Force) {
    throw "-n and -f are mutually exclusive"
}

if (!$DryRun -and !$Force) {
    throw "One of -n or -f must be specified"
}

dir -rec -fil $FilePattern | foreach {
    $path = Convert-Path $_.FullName
    $content = [IO.File]::ReadAllText($path);

    if ($Regex) {
        $content = [Regex]::Replace($content, $SearchString, $Replacement);
    } else {
        $content = $content.Replace($SearchString, $Replacement);
    }

    if ($DryRun) {
        $action = "Would be replacing"
    } else {
        $action = "Replacing"
    }
    Write-Host "$action '$SearchString' with '$Replacement' in '$path'"
    if($Force) {
        [IO.File]::WriteAllText($path, $content);
    }
}
