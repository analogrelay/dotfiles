if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

Write-Host "Configuring Git..."

$authorName = Read-Host " - What is your Git author name?"
$authorEmail = Read-Host " - What is your Git author email?"

$configBlob = @"
[user]
    name = $authorName
    email = $authorEmail
"@

$dotfilesGitPath = Join-Path $DotfilesRoot "git"
$gitAuthorFile = Join-Path $dotfilesGitPath "gitauthor.config"
$gitConfig = Join-Path $env:HOME ".gitconfig"
$gitConfigTemplate = Join-Path $dotfilesGitPath ".gitconfig"

$configBlob | Out-File $gitAuthorFile -Encoding UTF8

# Write the git config in place
if (Test-Path $gitConfig) {
    if (!(Confirm "Remove existing gitconfig" "A git config file already exists in '$gitConfig'. Remove it?")) {
        throw "User cancelled installation"
    }
    Remove-Item $gitConfig
}

Copy-Item $gitConfigTemplate $gitConfig
$configBlob | Out-File -Append -Encoding UTF8 -FilePath $gitConfig