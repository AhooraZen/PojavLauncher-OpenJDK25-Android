#!/usr/bin/env bash
set -e

JDK_REPO="${JDK_REPO:-https://github.com/openjdk/jdk}"
JDK_BRANCH="${JDK_BRANCH:-master}"

echo "Cloning OpenJDK 25 from $JDK_REPO ($JDK_BRANCH)..."
if [[ ! -d "jdk25" ]]; then
    git clone --depth 1 --branch "$JDK_BRANCH" "$JDK_REPO" jdk25
fi

cd jdk25

echo "Applying Android / PojavLauncher patches..."
for patch in ../patches/*.patch; do
    if [[ -f "$patch" ]]; then
        echo "Applying $patch..."
        patch -p1 --forward < "$patch" || echo "Patch $patch already applied or partially matched."
    fi
done

echo "=== Clone and Patch Completed ==="
