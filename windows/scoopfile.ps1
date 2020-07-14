bucket "nerd-fonts"

scoop "sudo"
scoop "Delugia-Nerd-Font" -Sudo

exe "fiddler" -TestPath "$env:LOCALAPPDATA/Programs/Fiddler/Fiddler.exe" -Source "https://telerik-fiddler.s3.amazonaws.com/fiddler/FiddlerSetup.exe" -Arguments @("/S")
exe "vscode" -TestPath "$env:LOCALAPPDATA/Programs/Microsoft VS Code/Code.exe" -Source "https://aka.ms/win32-x64-user-stable" -Arguments @("/VERYSILENT", "/NORESTART", "/MERGETASKS=!runcode") -Repath

msix "Microsoft.WindowsTerminal" -Source "https://github.com/microsoft/terminal/releases/download/v1.0.1811.0/Microsoft.WindowsTerminal_1.0.1811.0_8wekyb3d8bbwe.msixbundle"