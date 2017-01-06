$VisualStudios = @()
Export-ModuleMember -Variable VisualStudios

$ProductNodes = @(
    "VisualStudio",
    "VCExpress",
    "VPDExpress",
    "VSWinExpress",
    "VWDExpress",
    "WDExpress"
)

# I assume there will be a 15.0 :), who knows for sure? :P
$CtpVersions = @(
    New-Object System.Version "15.0"
)

$SearchRoot = "Software\Microsoft"
if($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
    $SearchRoot = "Software\Wow6432Node\Microsoft"
}

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
            if(Test-Path "$installDir\..\..\VC\vcvarsall.bat") {
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
                "Prerelease" = ($CtpVersions -contains $ver)
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
        "InstallDir" = $installDir;
        "VsVarsPath" = $vsVarsPath;
        "DevEnv" = $devenv;
        "Prerelease" = $true
    }
    $VisualStudios += $vsInfo
}

$DefaultVisualStudio = $VisualStudios | Where { $_.Product -eq "VisualStudio" } | sort Version -desc | select -first 1
Export-ModuleMember -Variable DefaultVisualStudio

function Import-VsVars {
    param(
        [Parameter(Mandatory=$false)][string]$Version = $null,
        [Parameter(Mandatory=$false)][string]$Product = "VisualStudio",
        [Parameter(Mandatory=$false)][string]$Architecture = $env:PROCESSOR_ARCHITECTURE,
        [Parameter(Mandatory=$false)][switch]$PrereleaseAllowed,
        [Parameter(Mandatory=$false)][switch]$WhatIf
    )

    Write-Debug "Finding vcvarsall.bat automatically..."

    # Find all versions of the specified product
    $vers = $VisualStudios | Where { $_.Product -eq $Product }

    $Vs = Get-VisualStudio -Version $Version -Product $Product |
        where { $PrereleaseAllowed -or !$_.Prerelease } |
        select -first 1

    if(!$Vs) {
        throw "No $Product Environments found"
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
        Write-Host "Imported Visual Studio $VsVersion Environment into current shell"
    } else {
        throw "Could not find VsVars batch file at: $VsVarsPath!"
    }
}
Export-ModuleMember -Function Import-VsVars

function Get-VisualStudio {
    param(
        [Parameter(Mandatory=$false, Position=1)][string]$Version,
        [Parameter(Mandatory=$false, Position=1)][string]$Product = "VisualStudio")
    # Find all versions of the specified product
    $vers = $VisualStudios | Where { $_.Product -eq $Product }

    $Vs = $null;
    if($Version) {
        $Vs = $vers | where { $_.Version -eq [System.Version]$Version }
    } else {
        $Vs = $vers | sort Version -desc
    }

    if(!$Vs) {
        if($Version) {
            throw "Could not find $Product $Version!"
        } else {
            throw "Could not find any $Product version!"
        }
    }
    $Vs
}
Export-ModuleMember -Function Get-VisualStudio

function Invoke-VisualStudio {
    param(
        [Parameter(Mandatory=$false, Position=0)][string]$Solution,
        [Parameter(Mandatory=$false, Position=1)][string]$Version,
        [Parameter(Mandatory=$false, Position=2)][string]$Product,
        [Parameter(Mandatory=$false)][switch]$Elevated,
        [Parameter(Mandatory=$false)][switch]$PrereleaseAllowed,
        [Parameter(Mandatory=$false)][switch]$WhatIf)

    # Load defaults from ".vslaunch" file
    if(Test-Path ".vslaunch") {
        $config = ConvertFrom-Json (cat -Raw ".vslaunch")
        if($config) {
            $Product = if($Product) { $Product } else { $config.product }
            $Version = if($Version) { $Version } else { $config.version }
            $Solution = if($Solution) { $Solution } else { $config.solution }
            $Elevated = if($Elevated) { $Elevated } else { $config.elevated }
        }
    }
    if(!$Product) {
        $Product = "VisualStudio";
    }
    Write-Debug "Launching: Product=$Product, Version=$Version, Solution=$Solution, Elevated=$Elevated"

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
        $devenvargs = @($slns[0])
    }

    $Vs = Get-VisualStudio -Version $Version -Product $Product |
        where { $PrereleaseAllowed -or !$_.Prerelease } |
        select -first 1
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
        throw "Could not find desired Visual Studio Product/Version: $Product v$Version"
    }
}
Set-Alias -Name vs -Value Invoke-VisualStudio
Export-ModuleMember -Function Invoke-VisualStudio -Alias vs
