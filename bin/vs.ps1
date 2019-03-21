param(
    [Parameter(Mandatory = $false, Position = 0)][string]$Solution,
    [Parameter(Mandatory = $false, Position = 1)][string]$Version,
    [Parameter(Mandatory = $false)][switch]$Elevated,
    [Parameter(Mandatory = $false)][switch]$WhatIf,
    [Parameter(Mandatory = $false)][switch]$NoPrerelease)

function VersionSegmentMatch([int]$requirement, [int]$target) {
    ($requirement -eq -1) -or ($requirement -eq $target)
}

# Determine if the target matches the requirement. Unlike Version.Equals this
# considers a missing segment equal to any value for the segment. So
# * 15.8.7.1 matches 15.8.7.1
# * 15.8.7 matches 15.8.7.1
# * 15.8 matches 15.8.7.1
# * 15 matches 15.8.7.1
function VersionMatch([Version]$requirement, [Version]$target) {
    (VersionSegmentMatch $requirement.Major $target.Major) -and
    (VersionSegmentMatch $requirement.Minor $target.Minor) -and
    (VersionSegmentMatch $requirement.Build $target.Build) -and
    (VersionSegmentMatch $requirement.Revision $target.Revision)
}

if (!(Get-Command vswhere -ErrorAction SilentlyContinue)) {
    throw "This command requires 'vswhere'"
}

if ([String]::IsNullOrEmpty($Solution)) {
    $Solution = "*.sln"
}
elseif (!$Solution.EndsWith(".sln")) {
    $Solution = "*" + $Solution + "*.sln";
}

$devenvargs = @();
if (!(Test-Path $Solution)) {
    Write-Host "Could not find any solutions. Launching VS without opening a solution."
}
else {
    $slns = @(dir $Solution)
    if ($slns.Length -gt 1) {
        $names = [String]::Join(",", @($slns | foreach { $_.Name }))
        throw "Ambiguous matches for $($Solution): $names";
    }
    $Solution = $slns[0]
    $devenvargs = @($slns[0])
}

# Check if the solution specifies a version
if ($Solution -and !$Version) {
    $line = cat $Solution | where { $_.StartsWith("VisualStudioVersion") } | select -first 1
    if ($line) {
        $ver = [System.Version]($line.Split("=")[1].Trim())

        # Strip everything but major/minor
        $MinVersion = [System.Version]"$($ver.Major).$($ver.Minor)"

        # If we have the matching version, we want to use it regardless of prerelease status
        $PrereleaseAllowed = $true
    }
}

# Load the Visual Studios
$VisualStudios = vswhere -all -prerelease -format json | ConvertFrom-json

# Filter out prereleases if they aren't allowed
if ($NoPrerelease) {
    $VisualStudios = $VisualStudios | Where-Object { !$_.isPrerelease }
}

# Determine the appropriate version
if ($Version) {
    # A specific version was requested.
    $VisualStudios = $VisualStudios | Where-Object {
        $ver = [Version]::Parse($_.installationVersion)
        VersionMatch $Version $ver
    }
}
elseif ($MinVersion) {
    # A minimum version was requested.
    $VisualStudios = $VisualStudios | Where-Object {
        if ($MinVersion) {
            $ver = [Version]::Parse($_.installationVersion)
            $ver -ge $MinVersion
        }
        else {
            $true
        }
    }
}

# Take the highest version available after filtering
$Vs = $VisualStudios | 
    Sort-Object @{Expression = {[Version]$_.installationVersion}} -Descending |
    Select -First 1

if (!$Vs) {
    $ver = "";
    if ($Version) {
        $ver = " $Version"
    }
    elseif ($MinVersion) {
        $ver = " >=$MinVersion"
    }
    throw "Could not find desired Visual Studio Version: $ver$nick"
}
elseif (@($Vs).Length -gt 1) {
    throw "Ambiguous match"
}

# Find devenv
$devenv = $Vs.productPath

if ($devenv) {
    if ($WhatIf) {
        Write-Host "Launching '$devenv $devenvargs'"
    }
    else {
        if ($Elevated) {
            elevate $devenv @devenvargs
        }
        else {
            &$devenv @devenvargs
        }
    }
}
else {
    throw "Desired Visual Studio ($($Vs.Version)) does not have a 'devenv' command associated with it!"
}