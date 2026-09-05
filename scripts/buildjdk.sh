#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/setdevkitpath.sh"

cd "$ROOT_DIR/jdk25"

export FREETYPE_DIR="$ROOT_DIR/build_deps/freetype-$BUILD_FREETYPE_VERSION/installed"
export CUPS_DIR="$ROOT_DIR/build_deps/cups"
export ALSA_DIR="$ROOT_DIR/build_deps/alsa"

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
    --with-toolchain-type=clang \
    --with-devkit="$TOOLCHAIN" \
    --with-sysroot="$TOOLCHAIN/sysroot" \
    CC="$CC" \
    CXX="$CXX" \
    BUILD_CC="$(which clang)" \
    BUILD_CXX="$(which clang++)" \
    BUILD_NM="$(which llvm-nm || which nm)" \
    BUILD_AR="$(which llvm-ar || which ar)" \
    BUILD_STRIP="$(which llvm-strip || which strip)" \
    BUILD_OBJCOPY="$(which llvm-objcopy || which objcopy)" \
    AR="$AR" \
    NM="$NM" \
    STRIP="$STRIP" \
    OBJCOPY="$OBJCOPY" \
    OBJDUMP="$OBJDUMP" \
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
    --with-alsa-include="$ALSA_DIR/include" \
    --with-alsa-lib="$ALSA_DIR/lib" \
    --with-fontconfig-include="$ANDROID_INCLUDE" \
    --x-includes="$ANDROID_INCLUDE/X11" \
    --enable-cds=no

echo "Building OpenJDK 25 (images target)..."
make images JOBS="$(nproc)"

echo "=== Build OpenJDK 25 complete ==="
