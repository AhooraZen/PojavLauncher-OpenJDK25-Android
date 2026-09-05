#!/usr/bin/env bash
set -e

# Defaults
export TARGET_VERSION=${TARGET_VERSION:-25}
export NDK_VERSION=${NDK_VERSION:-r28c}
export API=${API:-26}
export BUILD_FREETYPE_VERSION=${BUILD_FREETYPE_VERSION:-2.13.3}
export JDK_DEBUG_LEVEL=${JDK_DEBUG_LEVEL:-release}
export JVM_VARIANTS=${JVM_VARIANTS:-server}

if [[ -z "$ANDROID_NDK_HOME" ]]; then
    if [[ -d "$GITHUB_WORKSPACE/android-ndk-$NDK_VERSION" ]]; then
        export ANDROID_NDK_HOME="$GITHUB_WORKSPACE/android-ndk-$NDK_VERSION"
    elif [[ -d "/root/android-ndk-$NDK_VERSION" ]]; then
        export ANDROID_NDK_HOME="/root/android-ndk-$NDK_VERSION"
    elif [[ -d "/usr/local/lib/android/sdk/ndk/$NDK_VERSION" ]]; then
        export ANDROID_NDK_HOME="/usr/local/lib/android/sdk/ndk/$NDK_VERSION"
    else
        export ANDROID_NDK_HOME="$PWD/android-ndk-$NDK_VERSION"
    fi
fi

export TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"
export ANDROID_INCLUDE="$TOOLCHAIN/sysroot/usr/include"

case "$TARGET" in
    aarch64-linux-android)
        export TARGET_JDK="aarch64"
        export ARCH_FLAGS="-march=armv8-a"
        ;;
    arm-linux-androideabi)
        export TARGET_JDK="arm"
        export ARCH_FLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=neon"
        ;;
    x86_64-linux-android)
        export TARGET_JDK="x86_64"
        export ARCH_FLAGS="-march=x86-64"
        ;;
    i686-linux-android)
        export TARGET_JDK="x86"
        export ARCH_FLAGS="-march=i686 -mssse3 -mfpmath=sse"
        ;;
    *)
        echo "Unknown TARGET: $TARGET"
        exit 1
        ;;
esac

export CC="$TOOLCHAIN/bin/${TARGET}${API}-clang"
export CXX="$TOOLCHAIN/bin/${TARGET}${API}-clang++"
export AR="$TOOLCHAIN/bin/llvm-ar"
export AS="$TOOLCHAIN/bin/llvm-as"
export LD="$TOOLCHAIN/bin/ld.lld"
export NM="$TOOLCHAIN/bin/llvm-nm"
export OBJCOPY="$TOOLCHAIN/bin/llvm-objcopy"
export OBJDUMP="$TOOLCHAIN/bin/llvm-objdump"
export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
export STRIP="$TOOLCHAIN/bin/llvm-strip"

# Android 16 / 16KB Page Size Alignment and Compatibility Flags
export CFLAGS="-O3 $ARCH_FLAGS -D__ANDROID_API__=$API -D__ANDROID__ -I$ANDROID_INCLUDE -I$ANDROID_INCLUDE/$TARGET -fPIC"
export CXXFLAGS="$CFLAGS -stdlib=libc++"
# Enforce 16KB page boundary alignment on ELF binaries for Android 16 & future compatibility
export LDFLAGS="-Wl,-z,max-page-size=16384 -Wl,-z,common-page-size=16384 -llog -landroid -lc++_shared"

echo "=== Environment configured for $TARGET (Target JDK: $TARGET_JDK) ==="
