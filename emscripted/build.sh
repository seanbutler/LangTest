#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
EMSDK_ENV="$DIR/emsdk/emsdk_env.sh"

# Auto-source the local emsdk if emcmake isn't already on PATH.
if ! command -v emcmake &>/dev/null; then
    if [ -f "$EMSDK_ENV" ]; then
        echo "Sourcing Emscripten environment from $EMSDK_ENV"
        # shellcheck disable=SC1090
        source "$EMSDK_ENV"
    else
        echo "Error: emcmake not found and no local emsdk detected."
        echo "Run setup.sh first:  $DIR/setup.sh"
        exit 1
    fi
fi

# Always reconfigure cleanly to avoid stale CMake cache.
rm -rf "$DIR/build"

emcmake cmake -B "$DIR/build" -S "$DIR"
cmake --build "$DIR/build"

echo ""
echo "Build complete."
echo "  vo.js   — $DIR/build/vo.js"
echo "  vo.wasm — $DIR/build/vo.wasm"
echo "  vo.data — $DIR/build/vo.data  (preloaded VO stdlib)"
echo ""
echo "Serve and open:"
echo "  python3 -m http.server 8080 --directory $DIR/.."
echo "  open http://localhost:8080/emscripted/index.html"
