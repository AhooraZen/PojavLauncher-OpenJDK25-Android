#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/setdevkitpath.sh"

mkdir -p "$ROOT_DIR/build_deps"
cd "$ROOT_DIR/build_deps"

# Download FreeType official release tarball (self-contained, no git submodules required)
if [[ ! -d "freetype-$BUILD_FREETYPE_VERSION" ]]; then
    echo "Downloading FreeType $BUILD_FREETYPE_VERSION official tarball..."
    curl -sSL --connect-timeout 15 --max-time 120 -f "https://download.savannah.gnu.org/releases/freetype/freetype-$BUILD_FREETYPE_VERSION.tar.gz" -o freetype.tar.gz || \
    curl -sSL --connect-timeout 15 --max-time 120 -f "https://netcologne.dl.sourceforge.net/project/freetype/freetype2/$BUILD_FREETYPE_VERSION/freetype-$BUILD_FREETYPE_VERSION.tar.gz" -o freetype.tar.gz || \
    curl -sSL --connect-timeout 15 --max-time 120 -f "https://sourceforge.net/projects/freetype/files/freetype2/$BUILD_FREETYPE_VERSION/freetype-$BUILD_FREETYPE_VERSION.tar.gz/download" -o freetype.tar.gz

    mkdir -p "freetype-$BUILD_FREETYPE_VERSION"
    tar -xzf freetype.tar.gz --strip-components=1 -C "freetype-$BUILD_FREETYPE_VERSION"
fi

# Build FreeType for Android
echo "Building FreeType for $TARGET..."
cd "freetype-$BUILD_FREETYPE_VERSION"

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
