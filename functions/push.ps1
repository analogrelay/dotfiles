param([string]$Branch, [switch][alias("f")]$Force)

$ProtectedBranches = @(
    "dev",
    "master",
    "release")

if(!$Branch) {
    $Branch = git rev-parse --abbrev-ref HEAD
}

if($Force -and ($ProtectedBranches -icontains $Branch)) {
    throw "Unable to force-push protected branch $Branch from this command"
} elseif($Force) {
    Write-Host "git push origin $Branch --force"
    git push origin $Branch --force
} else {
    Write-Host "git push origin $Branch"
    git push origin $Branch
}
