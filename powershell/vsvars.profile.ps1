if(!(Get-Command vswhere -ErrorAction SilentlyContinue)) {
    # Install vswhere
    Install-Package vswhere -Provider Chocolatey
}

# Import the VS Vars
$installationPath = vswhere -prerelease -latest -property installationPath
if ($installationPath -and (test-path "$installationPath\Common7\Tools\vsdevcmd.bat")) {
  & "${env:COMSPEC}" /s /c "`"$installationPath\Common7\Tools\vsdevcmd.bat`" -no_logo && set" | foreach-object {
    $name, $value = $_ -split '=', 2
    set-content env:\"$name" $value
  }
}