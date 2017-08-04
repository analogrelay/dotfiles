Set-Alias cd Push-Location -Option AllScope
Set-Alias bd Pop-Location -Option AllScope
Set-Alias cdi Set-Location -Option AllScope

function global:hd() {
    Get-Location -Stack
}