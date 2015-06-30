param([string]$Project)

if(!$Project) {
    dnu build
} else {
    $candidates = @(dir | where { $_.PSIsContainer -and ($_.Name.Contains($Project)) })
    if(!$candidates -or ($candidates.Length -eq 0)) {
        $candidates = @(dir src | where { $_.PSIsContainer -and ($_.Name.Contains($Project)) })
    }
    if($candidates.Length -eq 1) {
        dnu build ($candidates[0].FullName)
    } else {
        Write-Host "Ambiguous Match: $Project. Candidates:"
        $candidates
    }
}

