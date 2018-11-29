if(Get-Command code.cmd -ErrorAction SilentlyContinue) {
    code @args
} else {
    throw "Visual Studio Code is not installed"
}