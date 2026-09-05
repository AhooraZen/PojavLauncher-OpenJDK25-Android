#!/usr/bin/env bash
set -e

source "$(dirname "$0")/setdevkitpath.sh"

OUTPUT_DIR="jdk25/build/linux-${TARGET_JDK}-${JDK_DEBUG_LEVEL}/images/jdk"
TAR_NAME="openjdk-25-${TARGET_JDK}-android16-pojav.tar.xz"

if [[ ! -d "$OUTPUT_DIR" ]]; then
    # Fallback search if path structure differs slightly
    OUTPUT_DIR=$(find jdk25/build -type d -name "jdk" | head -n 1)
fi

if [[ -z "$OUTPUT_DIR" || ! -d "$OUTPUT_DIR" ]]; then
    echo "Error: JDK build output directory not found!"
    exit 1
fi

echo "Stripping debug symbols..."
find "$OUTPUT_DIR/lib" "$OUTPUT_DIR/bin" -type f -name "*.so" -o -type f -perm /111 -exec $STRIP --strip-unneeded {} + 2>/dev/null || true

echo "Packaging OpenJDK 25 to $TAR_NAME..."
tar -cJf "$TAR_NAME" -C "$(dirname "$OUTPUT_DIR")" "$(basename "$OUTPUT_DIR")"

echo "Package created: $TAR_NAME"
ls -lh "$TAR_NAME"
