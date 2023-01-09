if (!(Get-Command starship -ErrorAction Silent)) {
    return
}

Invoke-Expression (&starship init powershell)