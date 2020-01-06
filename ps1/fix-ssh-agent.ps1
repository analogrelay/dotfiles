$sshAgentService = Get-Service ssh-agent -ErrorAction SilentlyContinue
if ($sshAgentService) {
    if ($sshAgentService.StartupType -eq "Disabled") {
        Write-Host -ForegroundColor Green "Undisabled ssh-agent."
        Set-Service $sshAgentService -StartupType Automatic
    }
}