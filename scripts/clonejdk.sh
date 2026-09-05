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
        if patch -p1 -N --dry-run < "$patch" >/dev/null 2>&1; then
            patch -p1 -N < "$patch"
            echo "Patch $(basename "$patch") successfully applied."
        elif patch -p1 -N -l --dry-run < "$patch" >/dev/null 2>&1; then
            patch -p1 -N -l < "$patch"
            echo "Patch $(basename "$patch") applied with whitespace tolerance."
        elif patch -p1 -N -F3 --dry-run < "$patch" >/dev/null 2>&1; then
            patch -p1 -N -F3 < "$patch"
            echo "Patch $(basename "$patch") applied with fuzz."
        else
            echo "Patch $(basename "$patch") already applied or failed dry-run, attempting direct patch..."
            patch -p1 -N -r - < "$patch" || echo "Patch $(basename "$patch") skipped."
        fi
    fi
done

echo "=== Clone and Patch Completed ==="
