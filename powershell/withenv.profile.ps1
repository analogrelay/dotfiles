function global:withenv {
    param(
        [Parameter(Mandatory=$false, Position=0)][string[]]$EnvironmentVariables,
        [Parameter(Mandatory=$true, Position=1)][ScriptBlock]$Code)

    $oldVars = @{};
    $EnvironmentVariables | ForEach-Object {
        $splat = $_.Split("=")
        $key = $splat[0];
        $value = $splat[1];

        if(Test-Path "env:\$key") {
            $oldVars[$key] = cat env:\$key
        } else {
            $oldVars[$key] = $null
        }

        Set-Item "env:\$key" $value
    }

    $Code.Invoke();

    $oldVars.Keys | ForEach-Object {
        $value = $oldVars[$_]

        if($value -eq $null) {
            del "env:\$_"
        } else {
            Set-Item "env:\$_" $value
        }
    }
}
