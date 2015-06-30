param([string]$Project)

if(!$Project) {
    dnx . test
} else {
    $candidates = @(dir | where { $_.PSIsContainer -and ($_.Name.Contains($Project)) })
    if(!$candidates -or ($candidates.Length -eq 0)) {
        $candidates = @(dir test | where { $_.PSIsContainer -and ($_.Name.Contains($Project)) })
    }
    if($candidates.Length -eq 1) {
        dnx ($candidates[0].FullName) test
    } else {
        Write-Host "Ambiguous Match: $Project. Candidates:"
        $candidates
    }
}

