#!/usr/bin/env bash
set -e

JDK_REPO="${JDK_REPO:-https://github.com/openjdk/jdk}"
JDK_BRANCH="${JDK_BRANCH:-master}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Cloning OpenJDK 25 from $JDK_REPO ($JDK_BRANCH)..."
if [[ ! -d "$ROOT_DIR/jdk25" ]]; then
    git clone --depth 1 --branch "$JDK_BRANCH" "$JDK_REPO" "$ROOT_DIR/jdk25"
fi

cd "$ROOT_DIR/jdk25"

echo "Applying Android / PojavLauncher patches..."
for patch in "$ROOT_DIR"/patches/*.patch; do
    if [[ -f "$patch" ]]; then
        echo "Applying $patch..."
        patch -p1 -N -r - < "$patch" || echo "Patch $(basename "$patch") skipped or already applied."
    fi
done

echo "=== Clone and Patch Completed ==="
