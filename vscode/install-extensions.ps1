$exts = @(Get-Content "$PSScriptRoot/extensions.txt" |
    ForEach-Object { $_.Trim() } |
    Where-Object { ![string]::IsNullOrEmpty($_) -and !$_.StartsWith("#") })
$codeArgs = @()
$exts | ForEach-Object {
    $codeArgs += @("--install-extension", $_)
}

if ($codeArgs) {
    code @codeArgs
}

if (Get-Process code) {
    Write-Warning "Existing instances of VS Code may need to be restarted"
}