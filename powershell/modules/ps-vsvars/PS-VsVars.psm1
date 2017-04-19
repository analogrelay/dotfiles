$ProductNodes = @(
    "VisualStudio",
    "VCExpress",
    "VPDExpress",
    "VSWinExpress",
    "VWDExpress",
    "WDExpress"
)

$SearchRoot = "Software\Microsoft"
if($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
    $SearchRoot = "Software\Wow6432Node\Microsoft"
}

function _LoadVisualStudios {
    $VisualStudios = @()
    $ProductNodes | ForEach-Object {
        $product = $_;
        $root = "HKLM:\$SearchRoot\$product"
        if(Test-Path $root) {
            dir "$root" | Where-Object {
                ($_.Name -match "\d+\.\d+") -and
                (![String]::IsNullOrEmpty((Get-ItemProperty "$root\$($_.PSChildName)").InstallDir)) 
            } | ForEach-Object {
                $regPath = "$root\$($_.PSChildName)"

                # Gather VS data
                $installDir = (Get-ItemProperty $regPath).InstallDir

                $vsVars = $null;
                if(Test-Path "$installDir\..\Tools\VsDevCmd.bat") {
                    $vsVars = Convert-Path "$installDir\..\Tools\VsDevCmd.bat"
                } elseif(Test-Path "$installDir\..\..\VC\vcvarsall.bat") {
                    $vsVars = Convert-Path "$installDir\..\..\VC\vcvarsall.bat"
                }
                $devenv = (Get-ItemProperty "$regPath\Setup\VS").EnvironmentPath;

                # Make a VSInfo object
                $ver = New-Object System.Version $_.PSChildName;
                $vsInfo = [PSCustomObject]@{
                    "Product" = $product;
                    "Version" = $ver;
                    "RegistryRoot" = $_;
                    "InstallDir" = $installDir;
                    "VsVarsPath" = $vsVars;
                    "DevEnv" = $devenv;
                }

                # Add it to the dictionary
                $VisualStudios += $vsInfo
            }
        }
    }

    # Find VS 2017 instances
    dir (Join-Path ([Environment]::GetFolderPath("CommonApplicationData")) "Microsoft\VisualStudio\Packages\_Instances") | ForEach-Object {
        $instanceRoot = $_
        $state = ConvertFrom-Json (Get-Content (Join-Path $instanceRoot.FullName "state.json"))

        $installDir = $state.installationPath
        $vsVarsPath = Join-Path $installDir "Common7\Tools\Vsdevcmd.bat"
        $devenv = Join-Path $installDir $state.launchParams.fileName

        $vsInfo = [PSCustomObject]@{
            "Product" = $state.catalogInfo.manifestName;
            "Edition" = $state.product.id;
            "Version" = (New-Object System.Version $state.catalogInfo.buildVersion);
            "Release" = $state.catalogInfo.productRelease;
            "InstallDir" = $installDir;
            "VsVarsPath" = $vsVarsPath;
            "DevEnv" = $devenv;
            "Nickname" = $state.properties.nickname
        }
        $VisualStudios += $vsInfo
    }

    $VisualStudios
}

function Import-VsVars {
    param(
        [Parameter(Mandatory=$false)][string]$Version = $null,
        [Parameter(Mandatory=$false)][string]$Architecture = $env:PROCESSOR_ARCHITECTURE,
        [Parameter(Mandatory=$false)][switch]$WhatIf
    )

    Write-Debug "Finding vcvarsall.bat automatically..."

    # Find all versions of the specified product
    $vers = $VisualStudios

    $Vs = Get-VisualStudio -Version $Version |
        where { $PrereleaseAllowed -or !$_.Prerelease } |
        select -first 1

    if(!$Vs) {
        throw "No Visual Studio Environments found"
    } else {
        Write-Debug "Found VS $($Vs.Version) in $($Vs.InstallDir)"
        $VsVarsPath = $Vs.VsVarsPath
    }

    if($VsVarsPath -and (Test-Path $VsVarsPath)) {
        # Run the cmd script
        if($Vs.Version -lt "15.0") {
            Write-Host "Invoking: `"$VsVarsPath`" $Architecture"
            if(!$WhatIf) {
                Invoke-CmdScript "$VsVarsPath" $Architecture
            }
        } else {
            $arch = $Architecture.ToLowerInvariant()
            Write-Host "Invoking: `"$VsVarsPath`" -arch=$arch"
            if(!$WhatIf) {
                Invoke-CmdScript "$VsVarsPath" "-arch=$arch"
            }
        }
        Write-Host "Imported Visual Studio $($Vs.Version) Environment into current shell"
    } else {
        throw "Could not find VsVars batch file at: $VsVarsPath!"
    }
}
Export-ModuleMember -Function Import-VsVars

function Get-VisualStudio {
    param(
        [Parameter(Mandatory=$false)][string]$Version,
        [Parameter(Mandatory=$false)][string]$MinVersion,
        [Parameter(Mandatory=$false)][string]$Nickname)

    # Find all versions of the specified product
    $vers = _LoadVisualStudios

    $Vs = $null;
    if($Version) {
        $Vs = $vers | where { $_.Version -eq [System.Version]$Version } | sort -desc Version
    } elseif($MinVersion) {
        $Vs = $vers | where { $_.Version.Major -eq ([System.Version]$MinVersion).Major -and $_.Version -ge [System.Version]$MinVersion } | sort -desc Version
    } else {
        $Vs = $vers | sort Version -desc
    }

    if($Nickname) {
        $Vs = $vers | where { $_.Nickname -like $Nickname }
    }

    if(!$Vs) {
        if($Version) {
            throw "Could not find Visual Studio $Version!"
        } else {
            throw "Could not find any Visual Studio version!"
        }
    }
    $Vs
}
Export-ModuleMember -Function Get-VisualStudio

function Invoke-VisualStudio {
    param(
        [Parameter(Mandatory=$false, Position=0)][string]$Solution,
        [Parameter(Mandatory=$false, Position=1)][string]$Version,
        [Parameter(Mandatory=$false)][string]$Nickname,
        [Parameter(Mandatory=$false)][switch]$Elevated,
        [Parameter(Mandatory=$false)][switch]$WhatIf)

    Write-Debug "Launching: Version=$Version, Solution=$Solution, Elevated=$Elevated"

    if([String]::IsNullOrEmpty($Solution)) {
        $Solution = "*.sln"
    }
    elseif(!$Solution.EndsWith(".sln")) {
        $Solution = "*" + $Solution + "*.sln";
    }

    $devenvargs = @();
    if(!(Test-Path $Solution)) {
        Write-Host "Could not find any solutions. Launching VS without opening a solution."
    }
    else {
        $slns = @(dir $Solution)
        if($slns.Length -gt 1) {
            $names = [String]::Join(",", @($slns | foreach { $_.Name }))
            throw "Ambiguous matches for $($Solution): $names";
        }
        $Solution = $slns[0]
        $devenvargs = @($slns[0])
    }

    # Check if the solution specifies a version
    if($Solution -and !$Version) {
        $line = cat $Solution | where { $_.StartsWith("VisualStudioVersion") } | select -first 1
        if($line) {
            $ver = [System.Version]($line.Split("=")[1].Trim())

            # Strip everything but major/minor
            $MinVersion = [System.Version]"$($ver.Major).$($ver.Minor)"

            # If we have the matching version, we want to use it regardless of prerelease status
            $PrereleaseAllowed = $true
        }
    }
    $Vs = Get-VisualStudio -MinVersion:$MinVersion -Nickname:$Nickname -Version:$Version |
        where {
            ([string]::IsNullOrEmpty($Nickname) -and [string]::IsNullOrEmpty($_.Nickname)) -or
            ($_.Nickname -eq $Nickname) }
        sort Version -desc |
        select -first 1

    if(!$Vs) {
        $ver = "";
        if($Version) {
            $ver = " $Version"
        } elseif($MinVersion) {
            $ver = " >=$MinVersion"
        }
        $nick = ""
        if($Nickname) {
            $nick = " ($Nickname)"
        }
        throw "Could not find desired Visual Studio Version: $ver$nick"
    }

    $devenv = $Vs.DevEnv

    if($devenv) {
        if($WhatIf) {
            Write-Host "Launching '$devenv $devenvargs'"
        }
        else {
            if($Elevated) {
                elevate $devenv @devenvargs
            }
            else {
                &$devenv @devenvargs
            }
        }
    } else {
        throw "Desired Visual Studio ($($Vs.Version)) does not have a 'devenv' command associated with it!"
    }
}
Set-Alias -Name vs -Value Invoke-VisualStudio
Export-ModuleMember -Function Invoke-VisualStudio -Alias vs
