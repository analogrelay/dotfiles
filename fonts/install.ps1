if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

if($PlatformIsWindows) {
    # Add additional extensions as needed
    $FontExtensions = @(".ttf")
    $ComShell = New-Object -ComObject Shell.Application

    Get-ChildItem $PSScriptRoot | Where-Object { $FontExtensions -contains $_.Extension } | ForEach-Object {
        $Source = Convert-Path $_.Directory.FullName
        Write-Host "Installing Font: $($_.Name)"
        $Ns = $ComShell.Namespace($Source)
        $Font = $Ns.ParseName($_.Name)
        $Font.InvokeVerb("install")
    }
}
else {
    Write-Warning "Installing fonts on non-Windows not yet supported!"
}