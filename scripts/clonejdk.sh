#!/usr/bin/env bash
set -e

JDK_REPO="${JDK_REPO:-https://github.com/openjdk/jdk25u}"
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
        echo "Applying $(basename "$patch")..."
        if ! patch -p1 -N --dry-run < "$patch" >/dev/null 2>&1; then
            echo "Patch $(basename "$patch") already applied or does not match, skipping."
        else
            patch -p1 -N < "$patch"
            echo "Patch $(basename "$patch") successfully applied."
        fi
    fi
done

echo "=== Clone and Patch Completed ==="
