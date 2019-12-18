if ($PSVersionTable.Platform -ne "Win32NT") {
    return;
}

# Find the latest VS version, including prereleases
$vsInstance = Get-VSSetupInstance -All -Prerelease | Sort-Object -Descending InstallationVersion | Select-Object -First 1
if (!$vsInstance) {
    Write-Debug "No Visual Studio Instances found. Skipping the import of VsVars."
    return;
}

Write-Host -ForegroundColor Green "Configuring $($vsInstance.DisplayName) ($($vsInstance.InstallationVersion)) Dev Shell"

# Try the new hotness, check for the devshell module
$DevShellModule = Join-Path $vsInstance.InstallationPath "Common7\Tools\vsdevshell\Microsoft.VisualStudio.DevShell.dll"
if (Test-Path $DevShellModule) {
    Write-Debug "Using built-in Visual Studio PowerShell module."
    Import-Module $DevShellModule
    try {
        Enter-VsDevShell -InstanceId $vsInstance.InstanceId -StartInPath (Get-Location)
    }
    catch {
        # Seems there are issues in PowerShell Core :(.
    }
}
else {
    Write-Warning "Visual Studio version does not contain PowerShell Module. Using fallback."

    $InstallationPath = vswhere -prerelease -latest -property installationPath

    if ($installationPath -and (test-path "$installationPath\Common7\Tools\vsdevcmd.bat")) {
        & "${env:COMSPEC}" /s /c "`"$installationPath\Common7\Tools\vsdevcmd.bat`" -no_logo -arch=amd64 && set" | foreach-object {
            $name, $value = $_ -split '=', 2

            # Special handling for PATH to ensure we don't just keep increasing the size of the variable as we switch architectures
            if ($name -eq "PATH") {
                $existingPath = $env:PATH.Split($PathSep)
                $newPath = @($value.Split($PathSep) | Where-Object { $existingPath -notcontains $_ })
                $global:_AddedByVsVars = $newPath
                $env:PATH = $value
            }
            else {
                Set-Content env:\"$name" $value
            }
        }
    }
}
