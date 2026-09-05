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
    --enable-shared=yes \
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

# Setup ALSA stub headers and libraries
if [[ ! -d "alsa" ]]; then
    echo "Setting up ALSA stub headers and library..."
    mkdir -p alsa/include/alsa
    cat << 'EOF' > alsa/include/alsa/asoundlib.h
#ifndef _ALSA_ASOUNDLIB_H
#define _ALSA_ASOUNDLIB_H
typedef struct _snd_pcm snd_pcm_t;
typedef struct _snd_pcm_hw_params snd_pcm_hw_params_t;
typedef struct _snd_pcm_sw_params snd_pcm_sw_params_t;
typedef struct _snd_mixer snd_mixer_t;
typedef struct _snd_mixer_elem snd_mixer_elem_t;
#endif
EOF
    mkdir -p alsa/lib
    "$AR" cru alsa/lib/libasound.a
fi

# Create dummy libraries so OpenJDK makefiles won't fail to link against them
mkdir -p "$ROOT_DIR/build_deps/dummy_libs"
"$AR" cru "$ROOT_DIR/build_deps/dummy_libs/libpthread.a"
"$AR" cru "$ROOT_DIR/build_deps/dummy_libs/librt.a"
"$AR" cru "$ROOT_DIR/build_deps/dummy_libs/libthread_db.a"
"$AR" cru "$ROOT_DIR/build_deps/dummy_libs/libasound.a"

# Symlink host X11 and fontconfig headers into Android NDK sysroot for headless compilation
if [[ -d "$ANDROID_INCLUDE" ]]; then
    echo "Symlinking X11 and fontconfig headers into $ANDROID_INCLUDE..."
    [[ -d /usr/include/X11 ]] && ln -s -f /usr/include/X11 "$ANDROID_INCLUDE/"
    [[ -d /usr/include/fontconfig ]] && ln -s -f /usr/include/fontconfig "$ANDROID_INCLUDE/"
    ln -s -f "$ROOT_DIR/build_deps/cups/cups" "$ANDROID_INCLUDE/"
fi

echo "=== Dependencies build complete ==="
