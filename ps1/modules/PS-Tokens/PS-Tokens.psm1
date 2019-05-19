# Loads tokens from a well-known (secure) path into variables
$TokensDirectory = Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) "PS-Tokens"

# Generate a "purpose" (aka "optional entropy") value so that our protected data doesn't look like other protected data.
$protectedDataEntropy = [System.Text.Encoding]::UTF8.GetBytes("PS-Tokens:V1")

if ($PSVersionTable.Platform -eq "Win32NT") {
    function _ProtectValue([string]$val) {
        $inputBytes = [System.Text.Encoding]::UTF8.GetBytes($val)
        $protectedBytes = [System.Security.Cryptography.ProtectedData]::Protect($inputBytes, $protectedDataEntropy, "CurrentUser")
        [Convert]::ToBase64String($protectedBytes)
    }

    function _UnprotectValue([string]$val) {
        $protectedBytes = [Convert]::FromBase64String($val)
        $outputBytes = [System.Security.Cryptography.ProtectedData]::Unprotect($protectedBytes, $protectedDataEntropy, "CurrentUser")
        [System.Text.Encoding]::UTF8.GetString($outputBytes)
    }
}
else {
    function _ProtectValue([string]$input) {
        Write-Warning "ProtectedData is not supported on non-Windows platforms. Tokens are stored in plaintext."
        $input
    }
    function _UnprotectValue([string]$input) { $input }
}

function _EnsureDir($name) {
    if (!(Test-Path $name)) {
        mkdir $name | Out-Null
    }
}

function _ResolveTokenFile($name) {
    Join-Path $TokensDirectory "$name.token.json"
}

function Remove-Token {
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Name)
    
    $file = _ResolveTokenFile $Name
    if (Test-Path $file) {
        Remove-Item $file
    }
}

function Get-Token {
    [CmdletBinding(DefaultParameterSetName = "ExcludeValue")]

    param(
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "IncludeValue")]
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "ExcludeValue")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "ExpandValue")]
        [string]$Filter,

        [Parameter(Mandatory = $true, ParameterSetName = "IncludeValue")][switch]$IncludeValue,
        [Parameter(Mandatory = $true, ParameterSetName = "ExpandValue")][switch]$ExpandValue)

    if ($ExpandValue) {
        $IncludeValue = $true
    }
    elseif (!$Filter) {
        $Filter = "*"
    }

    if (Test-Path $TokensDirectory) {
        $results = @(Get-ChildItem $TokensDirectory -Filter "$Filter.token.json" | ForEach-Object {
                $json = Get-Content $_.FullName | ConvertFrom-Json
                if (!$IncludeValue) {
                    $json.PSObject.Properties.Remove("Value")
                }
                else {
                    # Unprotect the value
                    $json.Value = _UnprotectValue $json.Value
                }
                $json
            })

        if ($ExpandValue) {
            if ($results.Count -gt 1) {
                throw "Ambiguous match! Multiple tokens matched the filter '$Name'"
            }
            elseif ($results.Count -gt 0) {
                $results[0].Value
            }
        }
        else {
            $results
        }
    }
}

function Set-Token(
    [Parameter(Mandatory = $true)][string]$TokenName,
    [Parameter(Mandatory = $true)][string]$TokenValue,
    [Parameter(Mandatory = $false)][string]$TokenDescription) {
    $TokenObj = [PSCustomObject]@{
        Name        = $TokenName;
        Description = $TokenDescription;
        Value       = _ProtectValue $TokenValue;
    }

    $TokenJson = $TokenObj | ConvertTo-Json

    $TokenFile = _ResolveTokenFile $TokenName
    _EnsureDir $TokensDirectory
    Set-Content -Path $TokenFile -Value $TokenJson
}