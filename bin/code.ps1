# Redirect to code-insiders if it exists
if(Get-Command code-insiders.cmd -ErrorAction SilentlyContinue) {
    code-insiders @args
} elseif(Get-Command code.cmd -ErrorAction SilentlyContinue) {
    code @args
} else {
    throw "Visual Studio Code is not installed"
}