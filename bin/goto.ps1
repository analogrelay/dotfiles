param([string]$Target)

# Collect all the candidates
$candidates = @(Get-ChildItem "C:\Code" -Depth 1 -Attributes Directory | Select-Object -Expand FullName)

if ($IsMacOS -or $IsWindows) {
    $candidates += @(
        (Join-Path $env:HOME "Downloads"),
        (Join-Path $env:HOME "Desktop"),
        (Join-Path $env:HOME "Documents")
    )
}

$candidates += @(
    (Join-Path $env:HOME ".dotfiles"),
    (Join-Path $env:HOME "kb"),
    "$CodeRoot"
)

# Some useful aliases
$aliases=@{}

if(Test-Path "$CodeRoot/github/github") {
    $aliases["dotcom"] = "$CodeRoot/github/github"
    $candidates += @("dotcom")
}

$qry_arg=@()
if ($Target) {
    $qry_arg=@("--query", "$Target", "--select-1", "--exit-0")
}

$target = $($candidates | fzf @qry_arg)

if ($LASTEXITCODE -ne 0) {
    throw "failed to find target to goto"
} else {
    if($aliases[$target]) {
        $target = $aliases[$target]
    }
    Set-Location $target
}