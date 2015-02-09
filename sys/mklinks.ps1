$links | foreach {
    Write-Host "mklink $($_["Link"]) => $($_["Target"])"
    New-Item -Type SymbolicLink -Path $_["Link"] -Value $_["Target"]
}

Write-Host "Finished! Press ENTER to continue..."
Read-Host