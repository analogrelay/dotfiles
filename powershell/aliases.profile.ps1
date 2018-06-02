Set-Alias grep select-string -Scope Global

if(Get-Command hub -ErrorAction SilentlyContinue) {
    Set-Alias git hub -Scope Global
}