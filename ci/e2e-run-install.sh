#!/bin/sh
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Launch a full esterOS install test onto the loopback disk created by e2e-setup.sh.
# Requires root (for partitioning/mount jobs).

set -eu

SRCDIR="${SRCDIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BUILDDIR="${BUILDDIR:-$SRCDIR/build}"
E2EDIR="$SRCDIR/e2e"
LOOP_FILE="$E2EDIR/.loop-device"
DISPLAY_NUM="${DISPLAY_NUM:-99}"
export DISPLAY=":${DISPLAY_NUM}"

if test ! -x "$BUILDDIR/calamares"; then
    echo "Calamares not built. Run: $SRCDIR/ci/e2e-setup.sh" >&2
    exit 1
fi

if test ! -f "$BUILDDIR/example.sqfs"; then
    echo "example.sqfs missing. Run: $SRCDIR/ci/e2e-setup.sh" >&2
    exit 1
fi

if test ! -f "$LOOP_FILE"; then
    echo "Loop device not set up. Run: $SRCDIR/ci/e2e-setup.sh" >&2
    exit 1
fi

LOOP_DEV=$(cat "$LOOP_FILE")
if ! sudo losetup "$LOOP_DEV" >/dev/null 2>&1; then
    echo "Re-attaching loop device..."
    LOOP_DEV=$(sudo losetup --find --show --partscan "$E2EDIR/target-disk.img")
    echo "$LOOP_DEV" > "$LOOP_FILE"
fi

# Start Xvfb if not already running
if ! xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
    echo "==> Starting Xvfb on $DISPLAY"
    Xvfb "$DISPLAY" -screen 0 1280x720x24 &
    XVFB_PID=$!
    trap 'kill "$XVFB_PID" 2>/dev/null || true' EXIT INT TERM
    sleep 1
fi

echo "==> Launching esterOS install test"
echo "    Working directory: $BUILDDIR"
echo "    Config:            $E2EDIR"
echo "    Loop device:       $LOOP_DEV"
echo "    DISPLAY=$DISPLAY"
echo ""
echo "In the partition step, select $LOOP_DEV and choose 'Erase disk'."
echo ""

cd "$BUILDDIR"
exec sudo -E env DISPLAY="$DISPLAY" ./calamares -d -c "$E2EDIR"
