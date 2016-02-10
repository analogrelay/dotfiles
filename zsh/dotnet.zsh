UNAME=$(uname)
if [ $UNAME = Darwin ]; then
    export DOTNET_REFERENCE_ASSEMBLIES_PATH=/Library/Frameworks/Mono.framework/Versions/Current/lib/mono/xbuild-frameworks
else if [ -d "/usr/local/lib/mono/xbuild-frameworks" ]; then
    export DOTNET_REFERENCE_ASSEMBLIES_PATH=/usr/local/lib/mono/xbuild-frameworks
else if [ -d "/usr/lib/mono/xbuild-frameworks" ]; then
    export DOTNET_REFERENCE_ASSEMBLIES_PATH=/usr/lib/mono/xbuild-frameworks
fi

