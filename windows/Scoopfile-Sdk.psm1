$Script:Definitions = @()

function exe {
    param(
        [Parameter(Mandatory=$true, Position=0)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Url,
        [Alias("cmd", "c")][Parameter(Mandatory=$false)][string]$Command,
        [Alias("args", "a")][Parameter(Mandatory=$false)][string[]]$Arguments
    )

    $Definition = [PSCustomObject]@{
        Name = $Name;
        Url = $Url;
        Command = $Command;
        Arguments = $Arguments;

        Check = $null;
        Install = { 
            param($def)
            $tempId = [Guid]::NewGuid().ToString("N")
            $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) "$tempId.exe"
            Write-Debug "Downloading '$($def.Url)' to '$tempFile'"
            Invoke-WebRequest -Uri $def.Url -OutFile $tempFile
            if (!(Test-Path $tempFile)) {
                throw "Download failed!"
            }
            Write-Debug "Running installer"
            $arguments = $def.Arguments
            & "$tempFile" @arguments
        }
    }
    if ($Command) {
        $Definition.Check = {
            param($def)
            !!(Get-Command "$($def.Command)*" | 
                Where-Object {
                    [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -eq $($def.Command)
                })
        }
    }

    $Script:Definitions += @($Definition)
}

function Get-Definitions {
    $Script:Definitions
}