param([string]$Path)

$Path = $Path.Replace("/", [IO.Path]::DirectorySeparatorChar)
$Path = Join-Path "Code:\" $Path

if(Test-Path $Path) {
    Set-Location $Path
}
