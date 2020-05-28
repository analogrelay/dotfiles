if ! has jq; then
    echo "Missing required component: 'jq'!"
    return 0
fi

_fonts_install_delugia() {
    # Load the installed version
    local INSTALLED_VERSION="<none>"
    if [ -e ~/Library/Fonts/DelugiaCode.version ]; then
        local INSTALLED_VERSION=`cat ~/Library/Fonts/DelugiaCode.version`
    fi

    # Check for the latest version
    VALS=(`curl -sSL https://api.github.com/repos/adam7/delugia-code/releases/latest | jq ".name, (.assets[] | select(.name == \"Delugia.Nerd.Font.Complete.ttf\").browser_download_url)"`)
    VERSION=`echo $VALS[1] | tr -d \"`
    URL=`echo $VALS[2] | tr -d \"`

    if [ "$VERSION" = "$INSTALLED_VERSION" ]; then
        trace_out "Not installing Delugia Code. Installed version '$INSTALLED_VERSION' matches latest version '$VERSION'"
        return 0
    else
        echo "Installing Delugia Code '$VERSION' because it is newer than installed version '$INSTALLED_VERSION'"
    fi

    # Check if the font exists
    if [ -e ~/Library/Fonts/Delugia.Nerd.Font.Complete.ttf ]; then
        rm ~/Library/Fonts/Delugia.Nerd.Font.Complete.ttf
    fi

    # Download it
    echo "Downloading Delugia Complete $VERSION from $URL ..."
    curl -o ~/Library/Fonts/Delugia.Nerd.Font.Complete.ttf -sSL $URL
    echo "$VERSION" > ~/Library/Fonts/DelugiaCode.version
}

_fonts_install_cascadia() {
    # Load the installed version
    local INSTALLED_VERSION="<none>"
    if [ -e ~/Library/Fonts/CascadiaCode.version ]; then
        local INSTALLED_VERSION=`cat ~/Library/Fonts/CascadiaCode.version`
    fi

    # Check for the latest version
    local VERSION=`curl -sSL https://api.github.com/repos/microsoft/cascadia-code/releases/latest | jq ".name" | tr -d \"`

    if [ "$VERSION" = "$INSTALLED_VERSION" ]; then
        trace_out "Not installing Cascadia Code. Installed version '$INSTALLED_VERSION' matches latest version '$VERSION'"
        return 0
    else
        echo "Installing '$VERSION' because it is newer than installed version '$INSTALLED_VERSION'"
    fi

    local URL=`curl -sSL https://api.github.com/repos/microsoft/cascadia-code/releases/latest | jq ".assets[] | select(.name | endswith(\".zip\")).browser_download_url" | tr -d \"`

    local DOWNLOAD_FILE=`mktemp`
    echo "Downloading $VERSION from $URL ..."
    if ! curl -o "$DOWNLOAD_FILE" -sSL "$URL"; then
        echo "Failed to download Cascadia Code!"
        return 1
    fi

    local FONTS=("ttf/CascadiaMonoPL.ttf" "ttf/CascadiaMono.ttf" "ttf/CascadiaCodePL.ttf" "ttf/CascadiaCode.ttf")
    
    echo "Extracting fonts: $FONTS"
    unzip -o $DOWNLOAD_FILE "$FONTS[@]" -j -d ~/Library/Fonts

    echo "$VERSION" > ~/Library/Fonts/CascadiaCode.version
}

_fonts_install_delugia
_fonts_install_cascadia
