Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

$env:PATH="$env:USERPROFILE\scoop\shims;$env:USERPROFILE"

if (!(Get-Command scoop -ErrorAction Silent)) {
    Write-Host -ForegroundColor Green "Installing Scoop..."
    
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

$installed = @{};
scoop list | ForEach-Object { $installed[$_.Name] = $_ }

function ensure($pkg) {
    if($installed[$pkg]) {
        Write-Host -ForegroundColor Green "Already installed: $pkg"
    } else {
        scoop install $pkg
    }
}

ensure pwsh
ensure starship
ensure git