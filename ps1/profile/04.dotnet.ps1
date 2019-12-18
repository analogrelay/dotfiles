# Put our dotnet.exe on the path first
if ($PSVersionTable["Platform"] -eq "Win32NT") {
    Add-PathVariable -Prepend "$env:HOME\.dotnet\x64"
}
else {
    Add-PathVariable -Prepend "$env:HOME\.dotnet"
}