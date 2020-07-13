$Script:Definitions = @()

function _fetchToTemp($url) {
    $response = Invoke-WebRequest $url
    Write-Debug "Downloading '$($def.Source)' ..."
    $fileName = $response.BaseResponse.Content.Headers.ContentDisposition.FileName
    if (!$fileName) {
        $fileName = "$([Guid]::NewGuid().ToString("N"))_content"
    }
    $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) $fileName
    if (Test-Path $tempFile) {
        Remove-Item $tempFile
    }
    Write-Debug "Saving to '$tempFile'"
    [System.IO.File]::WriteAllBytes($tempFile, $response.Content)
    $tempFile
}

function msix {
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Source
    )

    $Definition = [PSCustomObject]@{
        Name    = $Name;
        Source  = $Source;

        Check   = $null;
        Install = { 
            param($def)

            $tempFile = _fetchToTemp $Source
            try {
                if (!(Test-Path $tempFile)) {
                    throw "Download failed!"
                }

                Write-Debug "Installing MSIX bundle..."
                Add-AppxPackage -Path $tempFile
            }
            finally {
                if (Test-Path $tempFile) {
                    Remove-Item $tempFile
                }
            }
        }
    }

    $Script:Definitions += @($Definition)
    Write-Debug "Defined msix '$($Definition.Name)'"
}

function exe {
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $false)][switch]$Repath,
        [Alias("cmd", "c")][Parameter(Mandatory = $false)][string]$Command,
        [Alias("path", "p")][Parameter(Mandatory = $false)][string]$TestPath,
        [Alias("args", "a")][Parameter(Mandatory = $false)][string[]]$Arguments
    )

    $Definition = [PSCustomObject]@{
        Name      = $Name;
        Source    = $Source;
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

            $tempFile = _fetchToTemp $Source
            try {
                if (!(Test-Path $tempFile)) {
                    throw "Download failed!"
                }
                Write-Debug "Running installer ..."
                $arguments = $def.Arguments
                Start-Process -FilePath "$tempFile" -ArgumentList $arguments -Wait
                Write-Debug "Installer complete."
            }
            finally {
                if (Test-Path $tempFile) {
                    Remove-Item $tempFile
                }
            }

            if ($def.Repath) {
                Write-Debug "Repathing..."
                $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
                $sep = [System.IO.Path]::PathSeparator
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