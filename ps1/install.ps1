if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

Write-Host "Installing PowerShell Profile ..."

if (Test-Path $Profile) {
    Remove-Item $Profile
}

$Profiles = @(
    $profile
)

if ($IsWindows) {
    $DocsRoot = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments)
    $Profiles += @(
        Join-Path (Join-Path "$DocsRoot" "WindowsPowerShell") "Microsoft.PowerShell_profile.ps1"
    )
}


$Profiles | ForEach-Object {
    if (!(Test-Path $_)) {
        $ProfileParent = Split-Path -Parent $_

        if(!(Test-Path $ProfileParent))
        {
            mkdir $ProfileParent | Out-Null
        }

        $Ps1Root = Join-Path $DotFilesRoot "ps1"
        $DotFilesProfile = Join-Path $Ps1Root "profile.ps1"

        ". $DotFilesProfile" | Out-File -FilePath $_ -Encoding UTF8
    }
}