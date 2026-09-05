# OpenJDK 25 Android Builder (PojavLauncher & Android 16 Ready)

Automated GitHub Actions workflow and toolchain scripts to compile **OpenJDK 25** for Android (PojavLauncher and compatible environments), with full support for **Android 16** (API 35/36) and **16 KB page size alignment**.

## Features

- **OpenJDK Version**: 25 (built with Boot JDK 24).
- **Target Architecture**: `aarch64` (ARM64)
- **Android 16 Compatibility**:
  - Android NDK `r28c` toolchain with LLVM/Clang.
  - Full ELF 16KB segment alignment (`-Wl,-z,max-page-size=16384 -Wl,-z,common-page-size=16384`).
  - Patches for Bionic libc, thread CPU time, and POSIX signal compatibility.
- **Packaging**: Direct `.tar.xz` output containing the stripped OpenJDK binary image ready for PojavLauncher runtime ingestion.

## Output Format

The build artifact is produced as `.tar.xz`:
- `openjdk-25-aarch64-android16-pojav.tar.xz`

## Manual Trigger

Trigger the build via GitHub Actions:
1. Go to **Actions** -> **Build OpenJDK 25 for PojavLauncher**.
2. Click **Run workflow**.
