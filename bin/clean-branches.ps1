param($TargetBranch, $Remote = "origin", [Alias("n")][switch]$WhatIf)

$UserName = "anurse"

if(!$TargetBranch) {
    $TargetBranch = git rev-parse --abbrev-ref HEAD
}

if($TargetBranch.Contains("anurse")) {
    throw "Cowardly refusing to clean branches merged into a branch with 'anurse' in the name: $TargetBranch"
}

Write-Host -ForegroundColor Green "Cleaning git branches that have been merged into $TargetBranch"

Write-Host -ForegroundColor Green "Scanning for merged local branches..."
$branches = @(git branch --merged "$TargetBranch" | foreach { $_.Trim() } | where { $_.StartsWith("$UserName/") })

if($branches.Length -gt 0) {
    Write-Host -ForegroundColor Green "Cleaning local branches: "
    $branches | ForEach { Write-Host "* $_" }

    if(!$WhatIf) {
        Write-Host "Continue? [y/N]: " -NoNewLine
        $result = Read-Host
        if($result -ne "y") {
            Write-Host "Cancelling"
            exit
        }
        git branch -D @($branches | ForEach { "$_" })
    }
} else {
    Write-Host "No local branches to clean"
}

Write-Host -ForegroundColor Green "Fetching latest from '$Remote'"
git fetch $Remote --prune

Write-Host -ForegroundColor Green "Scanning for merged remote branches..."
$branches = @(git branch -r --merged "$Remote/$TargetBranch" | foreach { $_.Trim().Substring("$Remote/".Length) } | where { $_.StartsWith("$UserName/") })

if($branches.Length -gt 0) {
    Write-Host -ForegroundColor Green "Cleaning remote branches: "
    $branches | ForEach { Write-Host "* $_" }

    if(!$WhatIf) {
        Write-Host "Continue? [y/N]: " -NoNewLine
        $result = Read-Host
        if($result -ne "y") {
            Write-Host "Cancelling"
            exit
        }
        git push origin @($branches | ForEach { ":$_" })

        Write-Host -ForegroundColor Green "Fetching and pruning remote branches from '$Remote'"
        git fetch $Remote --prune
    }
} else {
    Write-Host "No remote branches to clean"
}

Write-Host -ForegroundColor Green "Scanning for local branches without a remote equivalent..."
$remotes = @(git branch -r | foreach { $_.Trim().Substring("$Remote/".Length) } | where { $_.StartsWith("$UserName/") })
$locals = @(git branch | foreach { $_.Trim() } | where { $_.StartsWith("$UserName/") })
$candidates = $locals | where { $remotes -notcontains $_ }
Write-Host -ForegroundColor Green "Cleaning local branches: "
$candidates | ForEach { Write-Host "* $_" }

if(!$WhatIf) {
    Write-Host "Continue? [y/N]: " -NoNewLine
    $result = Read-Host
    if($result -ne "y") {
        $cmd = "git branch -D $(@($candidates | ForEach { `"$_`" }))"
        Write-Host "Cancelling"
        Write-Host "To delete them, run: $cmd"
        exit
    }
    git branch -D @($candidates | ForEach { "$_" })
}
