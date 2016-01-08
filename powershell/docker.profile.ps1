function global:docker-use($MachineName) {
    if($MachineName.Equals("none", "OrdinalIgnoreCase")) {
        del env:\DOCKER_*
    }
    else {
        docker-machine env --shell=powershell $MachineName | Invoke-Expression
    }
}

<#
.SYNOPSIS
    Prints the current working directory, mapped into the docker machine (assuming default settings)
#>
function global:docker-pwd {
    $current = Convert-Path (Get-Location)
    if(!$current.StartsWith("C:\Users")) {
        throw "Can't map docker paths unless they are under C:\Users. Sorry :("
    }
    $subpath = $current.Substring(3).Replace("\", "/")
    "/c/$subpath"
}

function global:dock([string]$Image = "ubuntu") {
    $dir = docker-pwd
    docker run -it --rm -v "$($dir):$($dir)" -w $dir $Image
}
