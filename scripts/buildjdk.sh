#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/setdevkitpath.sh"

cd "$ROOT_DIR/jdk25"

export FREETYPE_DIR="$ROOT_DIR/build_deps/freetype-$BUILD_FREETYPE_VERSION/installed"
export CUPS_DIR="$ROOT_DIR/build_deps/cups"

echo "Configuring OpenJDK 25 for $TARGET..."

BOOT_JDK_ARG=""
if [[ -n "$BOOT_JDK" && -d "$BOOT_JDK" ]]; then
    BOOT_JDK_ARG="--with-boot-jdk=$BOOT_JDK"
elif [[ -n "$JAVA_HOME" && -d "$JAVA_HOME" ]]; then
    BOOT_JDK_ARG="--with-boot-jdk=$JAVA_HOME"
fi

bash ./configure \
    $BOOT_JDK_ARG \
    --openjdk-target="$TARGET" \
    --with-extra-cflags="$CFLAGS" \
    --with-extra-cxxflags="$CXXFLAGS" \
    --with-extra-ldflags="$LDFLAGS" \
    --disable-warnings-as-errors \
    --enable-headless-only=yes \
    --with-jvm-variants="$JVM_VARIANTS" \
    --with-debug-level="$JDK_DEBUG_LEVEL" \
    --with-freetype-include="$FREETYPE_DIR/include/freetype2" \
    --with-freetype-lib="$FREETYPE_DIR/lib" \
    --with-cups-include="$CUPS_DIR" \
    --with-devkit="$TOOLCHAIN" \
    --with-toolchain-type=clang \
    --enable-cds=no

echo "Building OpenJDK 25 (images target)..."
make images JOBS="$(nproc)"

echo "=== Build OpenJDK 25 complete ==="
