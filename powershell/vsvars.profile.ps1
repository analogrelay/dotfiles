if(!(Get-Command vswhere -ErrorAction SilentlyContinue)) {
    # Install vswhere
    Install-Package vswhere -Provider Chocolatey
}

# Add a global function to enter different vsvars contexts
$global:_AddedByVsVars = @()

$PathSep = [IO.Path]::PathSeparator;
function global:_RemoveVsVarsFromPath() {
  $existingPath = $env:PATH.Split($PathSep)
  $newPath = @($existingPath | Where-Object { $global:_AddedByVsVars -notcontains $_ })
  $env:PATH = [string]::Join($PathSep, $newPath)
}

function global:Import-VsVars([string]$Architecture, [int]$Version = 15) {
  _RemoveVsVarsFromPath

  $VersionString = "[$Version.0,$($Version + 1).0)"

  # Import the VS Vars
  $ArchArg = ""
  if($Architecture) {
    $ArchArg = "-arch=$Architecture "
  }
  $installationPath = vswhere -prerelease -latest -property installationPath -version $VersionString
  if ($installationPath -and (test-path "$installationPath\Common7\Tools\vsdevcmd.bat")) {
    & "${env:COMSPEC}" /s /c "`"$installationPath\Common7\Tools\vsdevcmd.bat`" $ArchArg-no_logo && set" | foreach-object {
      $name, $value = $_ -split '=', 2

      # Special handling for PATH to ensure we don't just keep increasing the size of the variable as we switch architectures
      if($name -eq "PATH") {
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