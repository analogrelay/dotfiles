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
        Check = $null;
        Install = {
            $tempId = [Guid]::NewGuid().ToString("N")
            $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) "$tempId.exe"
            Write-Debug "Downloading '$uri' to '$tempFile'"
            Invoke-WebRequest -Uri $url -OutFile $tempFile
            if (!(Test-Path $tempFile)) {
                throw "Download failed!"
            }
            Write-Debug "Running installer"
            & "$tempFile" @Arguments
        }
    }
    if ($Command) {
        $Definition.Check = {
            !!(Get-Command "$Command*" | 
                Where-Object {
                    [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -eq $Command
                })
        }
    }

    $Script:Definitions += @($Definition)
}

function Get-Definitions {
    $Script:Definitions
}