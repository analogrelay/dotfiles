param([string]$Repo)

$splat = $Repo.Split("/")
if ($splat.Length -ne 2) {
    throw "Invalid Repo Name: $Repo"
}

$owner = $splat[0]
$repoName = $splat[1]

if(!(Test-Path "Code:\$owner")) {
    mkdir "Code:\$owner"
}

pushd "Code:\$owner"
git clone "git@github.com:$owner/$repoName"
popd
