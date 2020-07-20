if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

function _ConfigureGitSetting($setting, $prompt) {
    $currentValue = git config $setting
    if (!$currentValue) {
        $newValue = Read-Host " - $prompt"
        git config --file "$env:USERPROFILE/.gitlocal" $setting $newValue
    }
}

Write-Host "Configuring Git..."

New-Link -Target "$DotfilesRoot/git/gitconfig" -Destination "$env:USERPROFILE/.gitconfig"

# Check if we need to regenerate/update local config
_ConfigureGitSetting "github.user" "What is your GitHub username?"
_ConfigureGitSetting "user.name" "What is your Git author name?"
_ConfigureGitSetting "user.email" "What is your Git author email?"

$currentHelper = git config credential.helper
if ($currentHelper -ne "manager") {
    git config --file "$env:USERPROFILE/.gitlocal" credential.helper "manager"
    Write-Host "Updating git credential.helper to 'manager'"
}