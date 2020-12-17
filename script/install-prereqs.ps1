if (!(Get-Command pwsh -ErrorAction SilentlyContinue)) {
	$json = (Invoke-WebRequest api.github.com/repos/powershell/powershell/releases/latest).Content | ConvertFrom-Json
	$downloadUrl = $json.assets | Where-Object { $_.name.EndsWith("-win-x64.msi") } | Select-Object -First 1 -Expand browser_download_url

	Write-Host "Downloading PowerShell Core ..."
	$tempFile = Join-Path ([System.IO.Path]::GetTempPath()) "powershell.msi"
	Invoke-WebRequest $downloadUrl -OutFile $tempFile

	Write-Host "Installing PowerShell Core ..."
	Start-Process -Wait -FilePath msiexec -ArgumentList @("/passive","/i",$tempFile)
}