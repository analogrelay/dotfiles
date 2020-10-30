$schemes = @()
Get-ChildItem $PSScriptRoot -Filter "*.json" | ForEach-Object {
    $Name = [System.IO.Path]::GetFileNameWithoutExtension($_.FullName)
    $json = Get-Content $_.FullName | ConvertFrom-Json
    $SchemeJson = [PSCustomObject]@{
        name = $Name;
        background = $json."background";
        foreground = $json."foreground";
        black = $json."black";
        blue = $json."blue";
        green = $json."green";
        cyan = $json."cyan";
        red = $json."red";
        purple = $json."magenta";
        yellow = $json."yellow";
        white = $json."white";
        brightBlack = $json."brightBlack";
        brightBlue = $json."brightBlue";
        brightGreen = $json."brightGreen";
        brightCyan = $json."brightCyan";
        brightRed = $json."brightRed";
        brightPurple = $json."brightMagenta";
        brightYellow = $json."brightYellow";
        brightWhite = $json."brightWhite";
    }
    $schemes += @($SchemeJson)
}

$WintermSettings = Convert-Path "$PSScriptRoot/../windows/winterm/settings.json"

$settings = Get-Content $WintermSettings | ConvertFrom-Json

$settings.schemes = $schemes

$settings | ConvertTo-Json > $WintermSettings