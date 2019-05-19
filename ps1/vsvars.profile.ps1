if ($PSVersionTable.Platform -ne "Win32NT") {
    return;
}

$VsWhereUrl = "https://github.com/Microsoft/vswhere/releases/download/2.6.7/vswhere.exe"
if (!(Get-Command vswhere -ErrorAction SilentlyContinue)) {
    Write-Host "Installing vswhere..."
    $Dest = Join-Path $DotFilesBin "vswhere.exe"
    Invoke-WebRequest -Uri $VsWhereUrl -OutFile $Dest
}

# Add a global function to enter different vsvars contexts
$global:_AddedByVsVars = @()

$PathSep = [IO.Path]::PathSeparator;
function global:Remove-VsVars() {
    $existingPath = $env:PATH.Split($PathSep)
    $newPath = @($existingPath | Where-Object { $global:_AddedByVsVars -notcontains $_ })
    $env:PATH = [string]::Join($PathSep, $newPath)
}

function global:Import-VsVars([string]$Architecture, [int]$Version = -1) {
    Remove-VsVars

    $VersionString = "[$Version.0,$($Version + 1).0)"

    # Import the VS Vars
    $ArchArg = ""
    if ($Architecture) {
        $ArchArg = "-arch=$Architecture "
    }
    if ($Version -ge 0) {
        $installationPath = vswhere -prerelease -latest -property installationPath -version $VersionString
    }
    else {
        $installationPath = vswhere -prerelease -latest -property installationPath
    }

    if ($installationPath -and (test-path "$installationPath\Common7\Tools\vsdevcmd.bat")) {
        & "${env:COMSPEC}" /s /c "`"$installationPath\Common7\Tools\vsdevcmd.bat`" $ArchArg-no_logo && set" | foreach-object {
            $name, $value = $_ -split '=', 2

            # Special handling for PATH to ensure we don't just keep increasing the size of the variable as we switch architectures
            if ($name -eq "PATH") {
                $existingPath = $env:PATH.Split($PathSep)
                $newPath = @($value.Split($PathSep) | Where-Object { $existingPath -notcontains $_ })
                $global:_AddedByVsVars = $newPath
                $env:PATH = $value
            }
            else {
                set-content env:\"$name" $value
            }
        }
    }
}

# Enter the default architecture
Import-VsVars