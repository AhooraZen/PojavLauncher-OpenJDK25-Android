#!/usr/bin/env bash
set -e

ARCH="$1"

if [[ -z "$ARCH" ]]; then
    echo "Usage: $0 [aarch64|arm|x86_64|x86]"
    exit 1
fi

case "$ARCH" in
    aarch64)
        export TARGET="aarch64-linux-android"
        ;;
    arm|aarch32)
        export TARGET="arm-linux-androideabi"
        ;;
    x86_64)
        export TARGET="x86_64-linux-android"
        ;;
    x86|i686)
        export TARGET="i686-linux-android"
        ;;
    *)
        echo "Invalid arch: $ARCH"
        exit 1
        ;;
esac

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== 1. Building FreeType & Libs for $TARGET ==="
bash "$SCRIPT_DIR/getlibs.sh"

echo "=== 2. Cloning & Patching OpenJDK 25 ==="
bash "$SCRIPT_DIR/clonejdk.sh"

echo "=== 3. Compiling OpenJDK 25 ==="
bash "$SCRIPT_DIR/buildjdk.sh"

echo "=== 4. Packaging tar.xz ==="
bash "$SCRIPT_DIR/tarjdk.sh"
