param([string]$Path)

$json = Get-Content $Path | ConvertFrom-Json

$newJson = @{
  "terminal.background" = $json."background";
  "terminal.foreground" = $json."foreground";
  "terminal.ansiBlack" = $json."black";
  "terminal.ansiBlue" = $json."blue";
  "terminal.ansiBrightBlack" = $json."brightBlack";
  "terminal.ansiBrightBlue" = $json."brightBlue";
  "terminal.ansiBrightCyan" = $json."brightCyan";
  "terminal.ansiBrightGreen" = $json."brightGreen";
  "terminal.ansiBrightMagenta" = $json."brightMagenta";
  "terminal.ansiBrightRed" = $json."brightRed";
  "terminal.ansiBrightWhite" = $json."brightWhite";
  "terminal.ansiBrightYellow" = $json."brightYellow";
  "terminal.ansicyan" = $json."cyan";
  "terminal.ansiGreen" = $json."green";
  "terminal.ansiMagenta" = $json."magenta";
  "terminal.ansiRed" = $json."red";
  "terminal.ansiWhite" = $json."white";
  "terminal.ansiYellow" = $json."yellow";
}

Write-Host "This JSON can be used in the 'workspace.colorCustomization' setting in VSCode"
$newJson | ConvertTo-Json