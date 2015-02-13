$links | foreach {
	if($_ -ne $null) {
		if(Test-Path $_["Link"]) {
			Remove-Item $_["Link"]
		}

	    if((Get-Item $_["Target"]).PSIsContainer) {
	    	cmd /c mklink /J "$($_["Link"])" "$($_["Target"])"
	    }
	    else {
	    	cmd /c mklink "$($_["Link"])" "$($_["Target"])"
	    }
	}
}

Write-Host "Finished! Press ENTER to continue..."
Read-Host