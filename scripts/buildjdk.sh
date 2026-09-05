#!/usr/bin/env bash
set -e

source "$(dirname "$0")/setdevkitpath.sh"

cd jdk25

export FREETYPE_DIR="$PWD/../build_deps/freetype-$BUILD_FREETYPE_VERSION/installed"
export CUPS_DIR="$PWD/../build_deps/cups"

echo "Configuring OpenJDK 25 for $TARGET..."

bash ./configure \
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
