Set-Alias cd Push-Location -Option AllScope
Set-Alias bd Push-Location -Option AllScope

function global:hd() {
    Get-Location -Stack
}