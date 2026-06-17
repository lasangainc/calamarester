#!/bin/sh
# One-time / refresh setup: system deps, Calamares build, example.sqfs.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
SRCDIR=${SRCDIR:-$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)}
BUILDDIR=${BUILDDIR:-$SRCDIR/build}

echo "==> E2E setup: SRCDIR=$SRCDIR BUILDDIR=$BUILDDIR"

if command -v sudo >/dev/null 2>&1 && [ "$(id -u)" -ne 0 ]; then
    SUDO=sudo
else
    SUDO=
fi

if [ -f "$SRCDIR/ci/deps-ubuntu.sh" ]; then
    echo "==> Base Calamares build dependencies (deps-ubuntu.sh)"
    $SUDO bash "$SRCDIR/ci/deps-ubuntu.sh" || true
    $SUDO apt-get install -y ninja-build squashfs-tools g++ libstdc++-12-dev
fi

echo "==> E2E-specific packages (deps.sh)"
$SUDO bash "$SCRIPT_DIR/deps.sh"

export CC=${CC:-gcc}
export CXX=${CXX:-g++}
export CMAKE_ARGS=${CMAKE_ARGS:-"-DKDE_INSTALL_USE_QT_SYS_PATHS=ON -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON -DBUILD_SCHEMA_TESTING=ON -DCMAKE_INSTALL_PREFIX=$BUILDDIR/install"}

if [ ! -f "$BUILDDIR/build.ninja" ]; then
    echo "==> Configure (cmake)"
    cmake -S "$SRCDIR" -B "$BUILDDIR" -G Ninja $CMAKE_ARGS
fi

echo "==> Build calamares + example-distro"
ninja -C "$BUILDDIR" calamares example-distro

if [ ! -f "$BUILDDIR/example.sqfs" ]; then
    echo "! example.sqfs missing after example-distro target"
    exit 1
fi

echo "==> Optional: ninja install (ignored on failure)"
ninja -C "$BUILDDIR" install || true

echo "==> Deploy E2E settings into build tree"
cp "$SCRIPT_DIR/config/settings.conf" "$BUILDDIR/settings.conf"
cp "$SCRIPT_DIR/config/modules/unpackfs.conf" "$BUILDDIR/src/modules/unpackfs/unpackfs.conf"
cp "$SCRIPT_DIR/config/modules/bootloader.conf" "$BUILDDIR/src/modules/bootloader/bootloader.conf"

echo ""
echo "Setup complete."
echo "  Binary:     $BUILDDIR/calamares"
echo "  Example FS: $BUILDDIR/example.sqfs"
echo "  Run E2E:    $SCRIPT_DIR/run.sh"
