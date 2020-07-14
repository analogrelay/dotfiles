param([string]$Repo)

if (!$CodeRoot) {
    throw "Code root is unknown, cannot auto-clone."
}

# Detect input types.
if ($Repo -match "(ssh://)?git@ssh.dev.azure.com:v3/(?<owner>[a-zA-Z0-9-_\.]+)/[a-zA-Z0-9-_\.]+/(?<repo>[a-zA-Z0-9-_\.]+)/?") {
    $Owner = $matches["owner"]
    $RepoName = $matches["repo"]
}
elseif ($Repo -match "(ssh://)?[A-Za-z]@vs-ssh.visualstudio.com:v3/(?<owner>[a-zA-Z0-9-_\.]+)/[a-zA-Z0-9-\._]+/(?<repo>[a-zA-Z0-9-_\.]+)/?") {
    $Owner = $matches["owner"]
    $RepoName = $matches["repo"]
}
elseif ($Repo -match "(?<owner>[a-zA-Z0-9-_\.]+)(/|\\)(?<repo>[a-zA-Z0-9-_\.]+)") {
    $Owner = $matches["owner"]
    $RepoName = $matches["repo"]
    $Repo = "ssh://git@github.com/$Repo"
}
elseif ($Repo -match "(ssh://)?git@github.com/(?<owner>[a-zA-Z0-9-_\.]+)/(?<repo>[a-zA-Z0-9-_\.]+)(.git)?/?") {
    $Owner = $matches["owner"]
    $RepoName = $matches["repo"]
}
elseif ($Repo -match "https://(www\.)?github.com/(?<owner>[a-zA-Z0-9-_\.]+)/(?<repo>[a-zA-Z0-9-_\.]+)(.git)?/?") {
    $Owner = $matches["owner"]
    $RepoName = $matches["repo"]
}
else {
    throw "This script can only be used with 'ssh://' URLs or GitHub owner/repo references"
}

$Container = Join-Path $CodeRoot $Owner
$RepoPath = Join-Path $Container $RepoName

if (!(Test-Path $RepoPath)) {
    Write-Host "Cloning $Repo into $RepoPath"

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
}
else {
    Write-Host "Repo is already cloned, changing directory to it..."
}

Set-Location $RepoPath