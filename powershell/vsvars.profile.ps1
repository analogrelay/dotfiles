Import-VsVars -Architecture x86 | Out-Null

# Clear LIB. Not sure why it's broken, but it is
Remove-Item env:\LIB
