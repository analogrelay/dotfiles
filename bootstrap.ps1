# Bootstraps the installation of the dotfiles scripts from scratch

function Test-Command($CommandName) {
    # Calling Get-Command, even with ErrorAction SilentlyContinue, spams
    # $error with errors. This avoids that.
    !!(Get-Command "$CommandName*" | 
        Where-Object {
            [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -eq $CommandName
        })
}

# First, check for the App Installer package
if(!(Test-Command winget)) {
    throw "The dotfiles bootstrapper requires that you configure 'winget' manually. See https://github.com/microsoft/winget-cli for details."
}

# Install git so we can get the dotfiles repo down
Write-Host -ForegroundColor Green "Installing Git."
winget install --exact --id Git.Git

# Ask for a machine name
$response = "n"
while($response.ToLowerInvariant() -ne "y") {
    $MachineName = Read-Host "What do you want the machine name to be?"
    $response = Read-Host "Great, '$MachineName'. Is that correct? [y/N]"
}
Rename-Computer -NewName $MachineName

# Configure an SSH key
ssh-keygen -t rsa -b 4096 -C "$MachineName"

# Put it in the clipboard and then launch GitHub to set up the key
Write-Host -ForegroundColor Yellow "You need to install the key into your SSH Keys on GitHub before we can continue."
Write-Host -ForegroundColor Yellow "The public key is in your clipboard, launching the browser to the GitHub page to configure it."
Get-Content "~/.ssh/id_rsa.pub" | clip.exe
Start-Process "https://github.com/settings/ssh/new"

$response = "n"
while($response.ToLowerInvariant() -ne "y") {
    $response = Read-Host "Have you configured the SSH key in GitHub? [y/N]"
}

Write-Host -ForegroundColor Green "Cloning the dotfiles now!"
git clone git@github.com:anurse/dotfiles.git ~/.dotfiles

# Install pwsh to run the setup script
winget install --exact --id Microsoft.PowerShell

Write-Host -ForegroundColor Green "Launching setup script!"
pwsh.exe "~/.dotfiles/script/setup.ps1"