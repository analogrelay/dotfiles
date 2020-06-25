$PlistNameMappings = @{
    "Ansi 0 Color" = "black";
    "Ansi 1 Color" = "red";
    "Ansi 2 Color" = "green";
    "Ansi 3 Color" = "yellow";
    "Ansi 4 Color" = "blue";
    "Ansi 5 Color" = "magenta";
    "Ansi 6 Color" = "cyan";
    "Ansi 7 Color" = "white";
    "Ansi 8 Color" = "brightBlack";
    "Ansi 9 Color" = "brightRed";
    "Ansi 10 Color" = "brightGreen";
    "Ansi 11 Color" = "brightYellow";
    "Ansi 12 Color" = "brightBlue";
    "Ansi 13 Color" = "brightMagenta";
    "Ansi 14 Color" = "brightCyan";
    "Ansi 15 Color" = "brightWhite";
    "Background Color" = "background";
    "Badge Color" = "badge";
    "Bold Color" = "bold";
    "Cursor Color" = "cursor";
    "Cursor Guide Color" = "cursorGuide";
    "Cursor Text Color" = "cursorText";
    "Foreground Color" = "foreground";
    "Link Color" = "link";
    "Selected Text Color" = "selectedText";
    "Selection Color" = "selection";
};

function PlistToHash($root) {
    $i = 0
    $data = @{}
    $currentKey = $null
    foreach ($node in $root.ChildNodes) {
        switch ($node.LocalName)
        {
            "key" {
                if ($currentKey) {
                    $data[$currentKey] = $null
                }
                $currentKey = $node."#text"
            }
            "real" {
                if (!$currentKey) {
                    Write-Warning "Value without active key!"
                } else {
                    $data[$currentKey] = [double]($node."#text")
                    $currentKey = $null
                }
            }
            "dict" {
                if (!$currentKey) {
                    Write-Warning "Value without active key!"
                } else {
                    $data[$currentKey] = PlistToHash $node
                    $currentKey = $null
                }
            }
            "string" {
                if (!$currentKey) {
                    Write-Warning "Value without active key!"
                } else {
                    $data[$currentKey] = $node."#text"
                    $currentKey = $null
                }
            }
        }
    }
    $data
}

function DoubleColorToHex($color) {
    ([int]($color * 0xFF)).ToString("X2")
}

function DictColorToHex($dict) {
    $r = DoubleColorToHex $dict["Red Component"]
    $g = DoubleColorToHex $dict["Green Component"]
    $b = DoubleColorToHex $dict["Blue Component"]
    "#$r$g$b"
}

$iTermDir = Join-Path $PSScriptRoot "iterm"
Get-ChildItem "$iTermDir" -Filter *.itermcolors | ForEach-Object {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    $xml = [xml](Get-Content $_)
    $dict = PlistToHash $xml.plist.dict
    $newDict = @{}
    $dict.Keys | ForEach-Object {
        $mappedKey = $PlistNameMappings[$_]
        if ($mappedKey) {
            $color = DictColorToHex $dict[$_]
            $newDict[$mappedKey] = $color
        }
    }

    $json = $newDict | ConvertTo-Json
    $path = Join-Path "$PSScriptRoot" "$Name.json"
    $json > $path
}