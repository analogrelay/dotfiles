# Set up GOPATH
if(Test-Path Code:\) {
    if(!(Test-Path Code:\Go)) {
        mkdir Code:\Go | Out-Null
    }
    $env:GOPATH = (Convert-Path Code:\Go)
    $env:PATH="$env:GOPATH\bin;$env:PATH"
}
