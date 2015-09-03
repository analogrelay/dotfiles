function global:docker-use($MachineName) {
    if($MachineName.Equals("none", "OrdinalIgnoreCase")) {
        del env:\DOCKER_*
    }
    else {
        docker-machine env --shell=powershell $MachineName | Invoke-Expression
    }
}
