Write-Host -ForegroundColor Green "Running DotFiles Profile..."

# Load config
. "$PSScriptRoot\..\config.ps1"

# Load utils
. "$PSScriptRoot\utils.ps1"

# Gather scripts and run them
Get-ChildItem (Join-Path $PSScriptRoot "profile") -Filter *.ps1 | ForEach-Object {
    $matches = [Regex]::Match($_.Name, "(\d+)\.[^\.]+.ps1")
    if ($matches.Success) {
        [PSCustomObject]@{
            Order = [int]::Parse($matches.Groups[1].Value);
            Name  = $_.Name;
            Path  = $_.FullName;
        }
    }
    else {
        Write-Warning "Invalid profile script name: $($_.Name). Skipping"
    }
} | Sort-Object Order | ForEach-Object {
    Write-Debug "Running profile script: $($_.Path)"
    $duration = Measure-Command { . "$($_.Path)" }
    $Profile_ScriptTimings[$_.Name] = $duration
}
