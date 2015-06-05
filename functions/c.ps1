param([string]$Path)

$Path = $Path.Replace("/", [IO.Path]::DirectorySeparatorChar)

if(!$Path) {
    if($env:PROJECTS -and (Test-Path $env:PROJECTS)) {
        cd $env:PROJECTS
    }
    exit
}

$goproj = (Join-Path (Join-Path (Join-Path $env:GOPATH "src") "github.com") $Path)

if(Test-Path $goproj) {
    Set-Location $goproj
} else if $env:PROJECTS -and (Test-Path $env:PROJECTS) {
    $prj = Join-Path $env:PROJECTS $Path
    Set-Location $prj
} else {
    Write-Error "$Path is not a valid project in GOPATH or PROJECTS"
}
