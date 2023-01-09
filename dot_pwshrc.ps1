if (!$env:HOME -and $env:USERPROFILE) {
    $env:HOME = $env:USERPROFILE
}

$pwshrcd = Join-Path "$env:HOME" ".pwshrc.d"

function Add-Path($path, [switch]$Append) {
    $currentMembers = $env:PATH.Split(";")
    if($currentMembers -notcontains $path) {
        if($Append) {
            $env:PATH = "$env:PATH;$path"
        } else {
            $env:PATH = "$path;$env:PATH"
        }
    }
}

$scoopdir = Join-Path "$env:HOME" "scoop"
if(Test-Path $scoopdir) {
    $shimsdir = Join-Path "$scoopdir" "shims"
    Add-Path $shimsdir
}

Add-Path (Join-Path "$env:HOME" "bin")

if (Test-Path $pwshrcd) {
    Get-ChildItem $pwshrcd -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }
}