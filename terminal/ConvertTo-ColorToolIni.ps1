param([string]$Path)

$json = Get-Content $Path | ConvertFrom-Json

function fromhex([string]$inp) {
  [int]::Parse($inp, "HexNumber")
}

function hexToTriple([string]$inp) {
  if (!$inp.StartsWith("#")) {
    throw "Invalid hex color: $inp"
  }
  $r = fromhex $inp.Substring(1, 2)
  $g = fromhex $inp.Substring(3, 2)
  $b = fromhex $inp.Substring(5, 2)
  "$r,$g,$b"
}

$newIni = @"
[table]
DARK_BLACK = $(hexToTriple $json."black")
DARK_BLUE = $(hexToTriple $json."blue")
DARK_GREEN = $(hexToTriple $json."green")
DARK_CYAN = $(hexToTriple $json."cyan")
DARK_RED = $(hexToTriple $json."red")
DARK_MAGENTA = $(hexToTriple $json."magenta")
DARK_YELLOW = $(hexToTriple $json."yellow")
DARK_WHITE = $(hexToTriple $json."white")
BRIGHT_BLACK = $(hexToTriple $json."brightBlack")
BRIGHT_BLUE = $(hexToTriple $json."brightBlue")
BRIGHT_GREEN = $(hexToTriple $json."brightGreen")
BRIGHT_CYAN = $(hexToTriple $json."brightCyan")
BRIGHT_RED = $(hexToTriple $json."brightRed")
BRIGHT_MAGENTA = $(hexToTriple $json."brightMagenta")
BRIGHT_YELLOW = $(hexToTriple $json."brightYellow")
BRIGHT_WHITE = $(hexToTriple $json."brightWhite")

[screen]
FOREGROUND = DARK_WHITE
BACKGROUND = DARK_BLACK

[popup]
FOREGROUND = DARK_MAGENTA
BACKGROUND = BRIGHT_WHITE
"@

$newIni