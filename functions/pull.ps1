param([string]$Branch)

$CurrentBranch = git rev-parse --abbrev-ref HEAD

if(!$Branch) {
    $Branch = $CurrentBranch
}

Write-Host "git pull origin $Branch:$Branch"
git pull origin $Branch:$Branch
