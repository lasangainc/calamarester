#!/bin/sh
# Launch Calamares for interactive end-to-end testing (GUI via Xvfb or real display).
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
SRCDIR=${SRCDIR:-$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)}
BUILDDIR=${BUILDDIR:-$SRCDIR/build}
E2E_DISK=${CALAMARES_E2E_DISK:-/dev/vdb}
DISPLAY_NUM=${CALAMARES_E2E_DISPLAY:-99}

if [ ! -x "$BUILDDIR/calamares" ]; then
    echo "! Build first: $SCRIPT_DIR/setup.sh"
    exit 1
fi

if [ ! -f "$BUILDDIR/example.sqfs" ]; then
    echo "! Missing $BUILDDIR/example.sqfs — run: ninja -C $BUILDDIR example-distro"
    exit 1
fi

if [ ! -b "$E2E_DISK" ]; then
    echo "! Target block device $E2E_DISK not found."
    echo "  Set CALAMARES_E2E_DISK to a spare disk (never your root device)."
    exit 1
fi

if command -v sudo >/dev/null 2>&1 && [ "$(id -u)" -ne 0 ]; then
    SUDO=sudo
else
    SUDO=
fi

export DISPLAY=:${DISPLAY_NUM}
if ! pgrep -f "Xvfb :${DISPLAY_NUM}" >/dev/null 2>&1; then
    echo "==> Starting Xvfb on DISPLAY=$DISPLAY"
    Xvfb ":${DISPLAY_NUM}" -screen 0 1280x720x24 &
    sleep 1
fi

echo "================================================================"
echo " Calamares E2E — INTERACTIVE installer"
echo " Target disk for partitioning: $E2E_DISK"
echo " WARNING: Choosing 'Erase disk' on $E2E_DISK destroys all data on it."
echo " Settings: $BUILDDIR/settings.conf (deployed by setup.sh)"
echo " Run from: $BUILDDIR (required for -d module paths and example.sqfs)"
echo "================================================================"
echo ""
echo "In the partition step, select device $E2E_DISK and use 'Erase disk'."
echo ""

cd "$BUILDDIR"
export CALAMARES_E2E_DISK
exec $SUDO -E env DISPLAY="$DISPLAY" ./calamares -d -D8 "$@"
