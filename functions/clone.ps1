param([string]$Repo)

if($Repo.StartsWith("http://") -or $Repo.StartsWith("https://")) {
    throw "This script can only be used with 'ssh://' URLs or GitHub owner/repo references"
}

if(!$Repo.StartsWith("ssh://")) {
    $Repo = "ssh://git@github.com/$Repo"
}

$RepoUri = [Uri]$Repo;

# Identify the source
if($RepoUri.Host.EndsWith(".visualstudio.com")) {
    # Parse the owner and repo name:
    $Owner = "$($RepoUri.UserInfo).visualstudio.com/$($RepoUri.Segments[1].TrimEnd("/"))"
    $RepoName = $RepoUri.Segments[-1]
} elseif(($RepoUri.Host -eq "github.com") -or ($RepoUri.Host -eq "www.github.com")) {
    $Owner = $RepoUri.Segments[1].TrimEnd("/")
    $RepoName = $RepoUri.Segments[2].TrimEnd("/")
} else {
    throw "Unknown repository URL. Use standard 'git clone' for this"
}

$Container = Join-Path Code:\ $Owner

if(!(Test-Path $Container)) {
    mkdir $Container | Out-Null
}

pushd $Container
git clone $Repo $RepoName
popd
