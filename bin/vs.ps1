param(
    [Parameter(Mandatory = $false, Position = 0)][string]$Solution,
    [Parameter(Mandatory = $false, Position = 1)][string]$Version,
    [Parameter(Mandatory = $false)][switch]$Elevated,
    [Parameter(Mandatory = $false)][switch]$WhatIf,
    [Parameter(Mandatory = $false)][switch]$NoPrerelease,
    [Parameter(Mandatory = $false)][switch]$DoNotLoadProjects)

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

function TryFindSingleFile($pattern) {
    $Candidates = @(Get-ChildItem $pattern)
    if ($Candidates.Count -eq 1) {
        $Candidates[0]
    }
    elseif ($Candidates.Count -gt 1) {
        throw "Ambiguous matches for '$pattern': $Candidates"
    }
}

if ([String]::IsNullOrEmpty($Solution)) {
    $Solution = TryFindSingleFile "*.sln"
    if (!$Solution) {
        $Solution = TryFindSingleFile "*.slnf"
    }
    if (!$Solution) {
        $Solution = TryFindSingleFile "*.csproj"
    }
    if (!$Solution) {
        $Solution = TryFindSingleFile "*.*proj"
    }
}
elseif (!$Solution.EndsWith(".sln")) {
    $Solution = "*" + $Solution + "*.sln";
}

Write-Host "Launching project: $Solution"
$devenvargs = @($Solution);


if ($DoNotLoadProjects) {
    $devenvargs += @("/DoNotLoadProjects")
}

# Check if the solution specifies a version
if ($Solution -and !$Version) {
    $line = Get-Content $Solution | Where-Object { $_.StartsWith("VisualStudioVersion") } | Select-Object -first 1
    if ($line) {
        $ver = [System.Version]($line.Split("=")[1].Trim())

        # Strip everything but major/minor
        $MinVersion = [System.Version]"$($ver.Major).$($ver.Minor)"

        # If we have the matching version, we want to use it regardless of prerelease status
        $PrereleaseAllowed = $true
    }
}

# Load the Visual Studios
$VisualStudios = Get-VSSetupInstance -All -Prerelease

# Filter out prereleases if they aren't allowed
if ($NoPrerelease) {
    $VisualStudios = $VisualStudios | Where-Object { !$_.IsPrerelease }
}

# Determine the appropriate version
if ($Version) {
    # A specific version was requested.
    $VisualStudios = $VisualStudios | Where-Object {
        VersionMatch $Version $_.InstallationVersion
    }
}
elseif ($MinVersion) {
    # A minimum version was requested.
    $VisualStudios = $VisualStudios | Where-Object {
        if ($MinVersion) {
            $_.InstallationVersion -ge $MinVersion
        }
        else {
            $true
        }
    }
}

# Take the highest version available after filtering
$Vs = $VisualStudios | 
Sort-Object InstallationVersion -Descending |
Select-Object -First 1

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
$devenv = $Vs.ProductPath

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