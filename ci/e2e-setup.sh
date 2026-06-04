#!/bin/sh
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# One-time setup for esterOS Calamares end-to-end testing.
#
# Builds Calamares, creates example.sqfs, and attaches a loopback
# disk image for install testing.

set -eu

SRCDIR="${SRCDIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BUILDDIR="${BUILDDIR:-$SRCDIR/build}"
E2EDIR="$SRCDIR/e2e"
DISK_IMAGE="$E2EDIR/target-disk.img"
DISK_SIZE_GIB="${DISK_SIZE_GIB:-8}"
LOOP_FILE="$E2EDIR/.loop-device"

echo "==> esterOS Calamares E2E setup"
echo "    Source:  $SRCDIR"
echo "    Build:   $BUILDDIR"
echo "    E2E dir: $E2EDIR"

# --- Dependencies ---
if ! command -v ninja >/dev/null 2>&1; then
    echo "==> Installing build dependencies..."
    sudo bash "$SRCDIR/ci/deps-ubuntu.sh"
    sudo apt-get install -y ninja-build squashfs-tools g++ libstdc++-12-dev xvfb
fi

# --- Build Calamares ---
export CC="${CC:-gcc}"
export CXX="${CXX:-g++}"
export CMAKE_ARGS="${CMAKE_ARGS:--DKDE_INSTALL_USE_QT_SYS_PATHS=ON -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON -DBUILD_SCHEMA_TESTING=ON -DCMAKE_INSTALL_PREFIX=$BUILDDIR/install -DINSTALL_POLKIT=OFF}"

if test ! -x "$BUILDDIR/calamares"; then
    echo "==> Configuring Calamares..."
    cmake -S "$SRCDIR" -B "$BUILDDIR" -G Ninja $CMAKE_ARGS
    echo "==> Building Calamares (this may take a few minutes)..."
    ninja -C "$BUILDDIR"
else
    echo "==> Calamares binary already built at $BUILDDIR/calamares"
fi

# --- Example distro ---
if test ! -f "$BUILDDIR/example.sqfs"; then
    echo "==> Building example.sqfs..."
    ninja -C "$BUILDDIR" example-distro
else
    echo "==> example.sqfs already exists"
fi

# --- Loopback disk ---
if test ! -f "$DISK_IMAGE"; then
    echo "==> Creating ${DISK_SIZE_GIB} GiB loopback disk at $DISK_IMAGE"
    truncate -s "${DISK_SIZE_GIB}G" "$DISK_IMAGE"
else
    echo "==> Loopback disk image already exists at $DISK_IMAGE"
fi

# Detach any previous attachment of this image
if test -f "$LOOP_FILE"; then
    OLD_LOOP=$(cat "$LOOP_FILE")
    if losetup "$OLD_LOOP" >/dev/null 2>&1; then
        echo "==> Detaching previous loop device $OLD_LOOP"
        sudo losetup -d "$OLD_LOOP" || true
    fi
fi

# Attach loop device
LOOP_DEV=$(sudo losetup --find --show --partscan "$DISK_IMAGE")
echo "$LOOP_DEV" > "$LOOP_FILE"
echo "==> Attached $DISK_IMAGE to $LOOP_DEV"

# --- Branding symlink ---
mkdir -p "$E2EDIR/branding"
if test ! -e "$E2EDIR/branding/esteros"; then
    ln -sfn ../../src/branding/esteros "$E2EDIR/branding/esteros"
fi

# QML modules (required when using -c e2e/)
if test ! -e "$E2EDIR/qml"; then
    ln -sfn ../build/src/qml "$E2EDIR/qml"
fi

echo ""
echo "Setup complete."
echo ""
echo "  UI walkthrough (no root):  $SRCDIR/ci/e2e-run-gui.sh"
echo "  Full install (root):       $SRCDIR/ci/e2e-run-install.sh"
echo ""
echo "  Loop device for install:   $LOOP_DEV  (${DISK_SIZE_GIB} GiB)"
echo "  Target filesystem image:   $BUILDDIR/example.sqfs"
echo ""
