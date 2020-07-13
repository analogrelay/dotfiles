$Script:Definitions = @()

function exe {
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $false)][switch]$Repath,
        [Alias("cmd", "c")][Parameter(Mandatory = $false)][string]$Command,
        [Alias("path", "p")][Parameter(Mandatory = $false)][string]$TestPath,
        [Alias("args", "a")][Parameter(Mandatory = $false)][string[]]$Arguments
    )

    Write-Host "DebugPref: $DebugPreference"

    $Definition = [PSCustomObject]@{
        Name      = $Name;
        Url       = $Url;
        Command   = $Command;
        TestPath  = $TestPath;
        Arguments = $Arguments;
        Repath    = $Repath;

        Check     = {
            param($def)
            Write-Host "DBGPref: $DebugPreference"
            if ($def.TestPath) {
                Write-Debug "Testing path $($def.TestPath)"
                Test-Path $def.TestPath
            }
            elseif ($def.Command) {
                Write-Debug "Testing command $($def.Command)"
                !!(Get-Command "$($def.Command)*" | 
                    Where-Object {
                        [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -eq $($def.Command)
                    })
            }
        };
        Install   = { 
            param($def)

            $tempId = [Guid]::NewGuid().ToString("N")
            $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) "$tempId.exe"
            Write-Debug "Downloading '$($def.Url)' to '$tempFile'"
            Invoke-WebRequest -Uri $def.Url -OutFile $tempFile
            if (!(Test-Path $tempFile)) {
                throw "Download failed!"
            }
            Write-Debug "Running installer ..."
            $arguments = $def.Arguments
            Start-Process -FilePath "$tempFile" -ArgumentList @arguments -Wait
            Write-Debug "Installer complete."

            if ($def.Repath) {
                Write-Debug "Repathing..."
                $userPath = [Environment]::GetEnvironmentVariables("PATH", "User")
                $sep = [System.IO.Path]::PathSeparatorChar
                $userPathItems = $userPath.Split($sep)
                $envPATHItems = $env:PATH.Split($sep)

                $userPathItems | ForEach-Object {
                    if ($envPATHItems -notcontains $_) {
                        Write-Debug "Enpathing '$_'"
                        $env:PATH = "$_$Sep$env:PATH"
                    }
                }
            }
        }
    }

    $Script:Definitions += @($Definition)
    Write-Debug "Defined exe '$($Definition.Name)'"
}

function Get-Definitions {
    $Script:Definitions
}