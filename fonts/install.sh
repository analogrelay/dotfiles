# Fonts are a per-OS thing
if [ "$(uname)" = "Darwin" ]; then
    trace_out "Detected macOS"
    source "./fonts/install.darwin.sh"
fi
