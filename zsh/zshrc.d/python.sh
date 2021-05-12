# Add python scripts to the PATH
if type python3 >/dev/null 2>&1; then
    install_dir=$(python3 -c "import os, site; print(os.path.join(site.USER_BASE, 'Scripts' if os.name == 'nt' else 'bin'))")
    export PATH="$install_dir:$PATH"
fi