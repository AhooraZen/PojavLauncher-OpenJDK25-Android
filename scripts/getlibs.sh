#!/usr/bin/env bash
set -e

source "$(dirname "$0")/setdevkitpath.sh"

mkdir -p build_deps
cd build_deps

# Download FreeType
if [[ ! -d "freetype-$BUILD_FREETYPE_VERSION" ]]; then
    echo "Downloading FreeType $BUILD_FREETYPE_VERSION..."
    curl -sSL "https://download.savannah.gnu.org/releases/freetype/freetype-$BUILD_FREETYPE_VERSION.tar.xz" -o freetype.tar.xz
    tar -xf freetype.tar.xz
fi

# Build FreeType for Android
echo "Building FreeType for $TARGET..."
cd "freetype-$BUILD_FREETYPE_VERSION"
make distclean 2>/dev/null || true

./configure \
    --host="$TARGET" \
    --prefix="$PWD/installed" \
    --enable-static=yes \
    --enable-shared=no \
    --with-png=no \
    --with-zlib=no \
    --with-bzip2=no \
    --with-brotli=no \
    --with-harfbuzz=no \
    CC="$CC" \
    CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS"

make -j"$(nproc)"
make install
cd ..

# Download and extract dummy CUPS headers
if [[ ! -d "cups" ]]; then
    echo "Setting up CUPS stub headers..."
    mkdir -p cups/cups
    cat << 'EOF' > cups/cups/cups.h
#ifndef _CUPS_CUPS_H_
#define _CUPS_CUPS_H_
typedef struct cups_dest_s {
    char *name;
    char *instance;
    int is_default;
    int num_options;
} cups_dest_t;
#endif
EOF
    cat << 'EOF' > cups/cups/ppd.h
#ifndef _CUPS_PPD_H_
#define _CUPS_PPD_H_
#endif
EOF
fi

echo "=== Dependencies build complete ==="
