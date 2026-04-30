#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
EMSDK_DIR="$DIR/emsdk"

# ── prerequisites ─────────────────────────────────────────────────────────────

check() {
    if ! command -v "$1" &>/dev/null; then
        echo "Error: '$1' not found — please install it and re-run."
        exit 1
    fi
}

check git
check python3
check cmake

# ── clone emsdk if not already present ───────────────────────────────────────

if [ -d "$EMSDK_DIR" ]; then
    echo "emsdk directory already exists at $EMSDK_DIR"
    echo "Pulling latest emsdk metadata…"
    git -C "$EMSDK_DIR" pull --ff-only
else
    echo "Cloning emsdk…"
    git clone https://github.com/emscripten-core/emsdk.git "$EMSDK_DIR"
fi

# ── install and activate ──────────────────────────────────────────────────────

cd "$EMSDK_DIR"

echo "Installing latest Emscripten toolchain (this may take a few minutes)…"
./emsdk install latest

echo "Activating…"
./emsdk activate latest

# ── done ─────────────────────────────────────────────────────────────────────

echo ""
echo "Setup complete."
echo ""
echo "Before building, load the Emscripten environment into your shell:"
echo ""
echo "  source $EMSDK_DIR/emsdk_env.sh"
echo ""
echo "Then build and serve:"
echo ""
echo "  $DIR/build.sh"
echo "  python3 -m http.server 8080 --directory $DIR/.."
echo "  # open http://localhost:8080/emscripted/index.html"
