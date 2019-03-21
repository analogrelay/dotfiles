param([string]$Repo)

# Detect input types.
if ($Repo -match "(ssh://)?git@ssh.dev.azure.com:v3/(?<owner>[a-zA-Z0-9-_]+)/[a-zA-Z0-9-_]+/(?<repo>[a-zA-Z0-9-_]+)/?") {
    $Owner = $matches["owner"]
    $RepoName = $matches["repo"]
}
elseif ($Repo -match "(?<owner>[a-zA-Z0-9-_]+)/(?<repo>[a-zA-Z0-9-_]+)") {
    $Owner = $matches["owner"]
    $RepoName = $matches["repo"]
    $Repo = "ssh://git@github.com/$Repo"
}
elseif ($Repo -match "(ssh://)?git@github.com/(?<owner>[a-zA-Z0-9-_]+)/(?<repo>[a-zA-Z0-9-_]+)(.git)?/?") {
    $Owner = $matches["owner"]
    $RepoName = $matches["repo"]
}
elseif ($Repo -match "https://(www\.)?github.com/(?<owner>[a-zA-Z0-9-_]+)/(?<repo>[a-zA-Z0-9-_]+)(.git)?/?") {
    $Owner = $matches["owner"]
    $RepoName = $matches["repo"]
}
else {
    throw "This script can only be used with 'ssh://' URLs or GitHub owner/repo references"
}

Write-Host "Cloning $Repo into Code:\$Owner\$RepoName"

$Container = Join-Path Code:\ $Owner

if (!(Test-Path $Container)) {
    mkdir $Container | Out-Null
}

Push-Location $Container
try {
    git clone $Repo $RepoName
}
finally {
    Pop-Location
}