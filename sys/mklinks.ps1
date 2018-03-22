$links | foreach {
	if($_ -ne $null) {
		if(Test-Path $_["Link"]) {
			Remove-Item $_["Link"] -Recurse -Force
		}

	    if((Get-Item $_["Target"]).PSIsContainer) {
	    	cmd /c mklink /J "$($_["Link"])" "$($_["Target"])"
	    } elseif($_["HardLink"]) {
			cmd /c mklink /H "$($_["Link"])" "$($_["Target"])"
		} else {
	    	cmd /c mklink "$($_["Link"])" "$($_["Target"])"
	    }
	}
}

Write-Host "Finished! Press ENTER to continue..."
Read-Host