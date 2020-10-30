param([string]$Scoopfile = "$PSScriptRoot\Scoopfile")

function ParseOption([ref] $remaining, $options) {
    $commaIdx = $remaining.Value.IndexOf(";")
    if($commaIdx -lt 0) {
        $commaIdx = $remaining.Value.Length
    }

    $optstr = $remaining.Value.Substring(0, $commaIdx).Trim()
    $remaining.Value = $remaining.Value.Substring($commaIdx).Trim()

    $colonIdx = $optstr.IndexOf(":")
    if($colonIdx -lt 0) {
        throw "Invalid option '$optstr'"
    }
    $name = $optstr.Substring(0, $colonIdx).Trim()
    $value = $optstr.Substring($colonIdx + 1).Trim().TrimStart("`"").TrimEnd("`"")
    $options[$name] = $value
}

function ParseRule($input) {
    $spaceIdx = $_.IndexOf(" ")
    if ($spaceIdx -lt 0) {
        throw "Invalid rule: $input"
    }
    $type = $_.Substring(0, $spaceIdx)
    $remaining = $_.Substring($spaceIdx).Trim()

    $options = @{}
    $commaIdx = $remaining.IndexOf(",")
    if($commaIdx -ge 0) {
        $ident = $remaining.Substring(0, $commaIdx)
        $remaining = $remaining.Substring($commaIdx + 1)
        while($remaining.Length -gt 0) {
            ParseOption ([ref]$remaining) $options
        }
    }
    else {
        $ident = $remaining
    }

    $ident = $ident.TrimStart("`"").TrimEnd("`"")

    [PSCustomObject]@{
        Type = $type;
        Identifier = $ident;
        Options = $options;
    }
}

$Parsers = @{
    "bucket" = [scriptblock] { param($rule)
        $url = $rule.Options["url"]
        [PSCustomObject]@{
            Name = $rule.Identifier;
            Type = "bucket";
            Test = [scriptblock]::Create("@(scoop bucket list) -contains `"$($rule.Identifier)`"");
            Install = if($url) {
                [scriptblock]::Create("scoop bucket add `"$($rule.Identifier)`" `"$url`"")
            } else {
                [scriptblock]::Create("scoop bucket add `"$($rule.Identifier)`"")
            };
            InstallMessage = "Adding bucket `"$($rule.Identifier)`"";
        }
    };
    "scoop" = [scriptblock] { param($rule)
        [PSCustomObject]@{
            Name = $rule.Identifier;
            Type = "scoop";
            Test = [scriptblock]::Create("!(scoop info `"$($rule.Identifier)`" | Select-String `"Installed: No`")");
            Install = [scriptblock]::Create("scoop install `"$($rule.Identifier)`"");
        }
    }
}

$Rules = Get-Content $Scoopfile | ForEach-Object {
    $line = $_.Trim()
    if($line.StartsWith("#") -or [string]::IsNullOrEmpty($line)) {
        return
    }

    $rule = ParseRule $line
    $parser = $Parsers[$rule.Type]
    if(!$parser) {
        throw "Unknown rule type '$($rule.Type)'"
    }

    $parser.Invoke($rule)
}

$Rules