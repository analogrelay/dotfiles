# Fonts are a per-OS thing
if ismacos; then
    trace_out "Detected macOS"
    source "./fonts/install.darwin.sh"
fi
