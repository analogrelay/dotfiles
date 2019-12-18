# Identify the code root directory
if ($PSVersionTable.Platform -eq "Win32NT") {
    $CodeRoot = "C:\Code"
    $LegacyCodeRoot = (Join-Path $env:USERPROFILE "Code")

    if (!(Test-Path $CodeRoot) -and (Test-Path $LegacyCodeRoot)) {
        Write-Warning "The legacy code root: $LegacyCodeRoot exists but the new code root $CodeRoot does not."
        Write-Warning "Consider moving to the new code root to avoid long path issues on Windows."
    }
}
else {
    $CodeRoot = Convert-Path "~/code"
}

Write-Host -ForegroundColor Green "Code Root: $CodeRoot"
$env:PROJECTS = $CodeRoot
$env:CODE_ROOT = $CodeRoot
$global:CodeRoot = $CodeRoot