if (!$DotFilesInstalling) { throw "This script should only be run during dotfiles installation!" }

if (!(Test-Command gpg)) {
    throw "Cannot load gpg, it is not installed."
}

if(!(Test-Command op)) {
    throw "Cannot load gpg, onepassword-cli is not installed."
}

$KeyId="B86EA7CF15CD9B8CF46BA31862ADE1FEC51F9A1A"

$GpgDotfiles = Join-Path $DotFilesRoot "gpg"
$GpgDir = Join-Path $env:HOME ".gnupg"

if (!(Test-Path $GpgDir)) {
    New-Item -Type Directory $GpgDir | Out-Null
}

$GpgConfPath = Join-Path $GpgDir "gpg.conf"
$PublicKeyPath = Join-Path $GpgDir "andrew@stanton-nurse.com_gitsigning.public.gpg-key"
$PrivateKeyPath = Join-Path $GpgDir "andrew@stanton-nurse.com_gitsigning.private.gpg-key"

$GpgConfSource = Join-Path $GpgDotfiles "gpg.conf"
$PublicKeySource = Join-Path $GpgDotfiles "andrew@stanton-nurse.com_gitsigning.public.gpg-key"

New-Item -Force -Type SymbolicLink -Path $PublicKeyPath -Value $PublicKeySource | Out-Null

gpg --list-key "$KeyId" 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Debug "Key is already loaded!"
} else {
    gpg --import $PublicKeyPath

    gpg --list-secret-keys $KeyId 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        if (!$env:OP_SESSION_stanton_nurse) {
            Invoke-Expression $(op signin stanton-nurse.1password.com andrew@stanton-nurse.com)
        }

        op get document "andrew@stanton-nurse.com_gitsigning.private.gpg-key" > $PrivateKeyPath
        gpg --import $PrivateKeyPath
        Remove-Item -Force $PrivateKeyPath
    }
}

$GpgExe = scoop which gpg

$GitLocalConfig = Join-Path $env:HOME ".gitlocal"
$SigningKey = (gpg --list-signatures | Select-String "^sig 3\s+([A-Fa-f0-9]+).*$").Matches.Groups[1]
git config --file $GitLocalConfig user.signingkey "$SigningKey"
git config --file $GitLocalConfig commit.gpgsign true
git config --file $GitLocalConfig gpg.program "$GpgExe"

New-Item -Force -Type SymbolicLink -Path $GpgConfPath -Value $GpgConfSource | Out-Null