param(
    [switch]$Debug
)

. "$PSScriptRoot/ps1/utils.ps1"

function Install-DotFiles() {
    $DevModeRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"

    $DotFilesRoot = Convert-Path $PSScriptRoot

    # Dot-source the config file
    . "$DotFilesRoot/config.ps1"

    function Test-DeveloperMode() {
        if (Test-Path $DevModeRegPath) {
            (Get-ItemProperty $DevModeRegPath).AllowDevelopmentWithoutDevLicense -eq 1
        }
        else {
            $false
        }
    }

    # Check Windows Pre-requisites
    if ($PSVersionTable.Platform -eq "Win32NT") {
        $Global:PlatformIsWindows = $true
        Write-Debug "Running on Windows"
        if (Test-DeveloperMode) {
            Write-Debug "Developer mode is ENABLED!"
        }
        else {
            Write-Host "Developer mode must be enabled to create symbolic links."
            Write-Host "Launching Windows Settings to enable Developer Mode."
            Write-Host "Re-run this script after enabling Developer Mode to continue."
            Start-Process "ms-settings:developers"
            return
        }
    }
    else {
        $Global:PlatformIsOther = $true
    }

    # Run all Install scripts
    $DotFilesInstallScripts | ForEach-Object {
        $path = Join-Path $PSScriptRoot $_
        Write-Debug "Running Install Script $path ..."
        try {
            & "$path"
        }
        catch {
            Write-Error -ErrorRecord $Error[0]
            Write-Debug "Error during installation."
        }
    }
}

$oldDebugPref = $DebugPreference
if ($Debug) {
    $DebugPreference = "Continue"
}

try {
    $DotFilesInstalling = $true
    Install-DotFiles
}
finally {
    Remove-Item -Path variable:\DotFilesInstalling -ErrorAction SilentlyContinue
    if ($Debug) {
        $DebugPreference = $oldDebugPref
    }
}

# function TwoLevelRecursiveDir($filter) {
#     Get-ChildItem $DotFilesRoot | ForEach-Object {
#         if ($_.Name -like $filter) {
#             $_
#         }
#         if ($_.PSIsContainer) {
#             Get-ChildItem $_.FullName -filter $filter
#         }
#     }
# }

# TwoLevelRecursiveDir "*.copy" | ForEach-Object {
#     $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
#     $dest = Join-Path $UserProfile ".$name"
#     Write-Host "Copying $($_.Name) to profile as .$name"
#     Copy-Item $_.FullName $dest
# }

# TwoLevelRecursiveDir "*.symlink" | ForEach-Object {
#     $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
#     $link = Join-Path $UserProfile ".$name"
#     if (!(Test-Path $link)) {
#     }
# }

# # Run install scripts
# TwoLevelRecursiveDir "*.dotfiles.install.ps1" | foreach {
#     & $_.FullName
# }

# if ($DotFiles_LinksToCreate.Length -gt 0) {
#     Write-Host "Need to create $($DotFiles_LinksToCreate.Length) links. Elevating..."

#     $script = "`$links=@("
#     $first = $true;
#     $DotFiles_LinksToCreate | foreach {
#         if ($first) {
#             $first = $false
#         }
#         else {
#             $script += ","
#         }
#         $script += "@{`"Link`"=`"$($_["Link"])`";`"Target`"=`"$($_["Target"])`"}"
#     }
#     $script += ");& $PSScriptRoot\mklinks.ps1"
#     $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($script))

#     $psi = New-Object System.Diagnostics.ProcessStartInfo
#     $psi.FileName = "powershell"
#     $psi.Arguments = "-NoProfile -NoLogo -EncodedCommand $encoded"
#     $psi.Verb = "runas"
#     $p = [System.Diagnostics.Process]::Start($psi)
#     $p.WaitForExit()
# }
# else {
#     Write-Host "No links to create!"
# }

# # Write the boot profile script
# $profileDir = Split-Path -Parent $Profile
# if (!(Test-Path $profileDir)) {
#     mkdir $profileDir | Out-Null
# }
# ". $DotFiles_Root\powershell\profile.ps1" > $profile