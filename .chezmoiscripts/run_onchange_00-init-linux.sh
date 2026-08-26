#!/bin/bash

# Initializes the basic expected environment for a Linux system. This script is intended to be run as part of the Chezmoi configuration management process.
# This runs first, before even package installation, so it should be kept as minimal as possible. It requires sudo privileges to run (it will self-elevate though).

if [ $(uname) != "Linux" ]; then
    echo "This script is intended to be run on Linux systems only."
    exit 1
fi

# Capture the invoking user before self-elevation
INVOKING_USER="${SUDO_USER:-$USER}"

# Self-elevate to root if not already running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Attempting to elevate privileges..."
    exec sudo "$0" "$@"
fi

# Check the distro in use
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Cannot determine the Linux distribution. Exiting."
    exit 1
fi

# Install core packages.
case $DISTRO in
    ubuntu|debian)
        apt-get update
        apt-get install -y \
            curl \
            git \
            zsh \
            apt-transport-https \
            ca-certificates
        ;;
    *)
        echo "Unsupported Linux distribution: $DISTRO"
        exit 1
        ;;
esac

# If running in wsl, set up systemd by writing to /etc/wsl.conf
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    echo "Detected WSL environment. Configuring systemd..."
    cat <<EOL > /etc/wsl.conf
[boot]
systemd=true

[interop]
enabled=true
EOL
    echo "Systemd configuration for WSL written to /etc/wsl.conf."
    echo "Please restart your WSL instance for the changes to take effect."
fi

# Enable linger for the invoking user so user services persist after logout
if id "$INVOKING_USER" &>/dev/null; then
    echo "Enabling linger for user $INVOKING_USER..."
    loginctl enable-linger "$INVOKING_USER"
fi