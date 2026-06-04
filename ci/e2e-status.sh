#!/bin/sh
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Show the state of the e2e loopback test disk.

set -eu

SRCDIR="${SRCDIR:-$(cd "$(dirname "$0")/.." && pwd)}"
E2EDIR="$SRCDIR/e2e"
DISK_IMAGE="$E2EDIR/target-disk.img"
LOOP_FILE="$E2EDIR/.loop-device"

echo "==> esterOS E2E disk status"
echo ""

if test -f "$DISK_IMAGE"; then
    echo "  Image file:  $DISK_IMAGE ($(du -h "$DISK_IMAGE" | cut -f1))"
else
    echo "  Image file:  missing (run ./ci/e2e-setup.sh)"
fi

if test -f "$LOOP_FILE"; then
    LOOP_DEV=$(cat "$LOOP_FILE")
    if sudo losetup "$LOOP_DEV" >/dev/null 2>&1; then
        echo "  Loop device: $LOOP_DEV (attached)"
        sudo losetup "$LOOP_DEV"
    else
        echo "  Loop device: $LOOP_DEV (registered but not attached)"
        echo "               Run ./ci/e2e-setup.sh to re-attach"
    fi
else
    echo "  Loop device: not registered (run ./ci/e2e-setup.sh)"
fi

echo ""
echo "Note: the test disk should be attached but NOT mounted."
echo "      Calamares partitions and mounts it during install."
echo "      Full install must run as root: ./ci/e2e-run-install.sh"
echo ""

if ! command -v sfdisk >/dev/null 2>&1; then
    echo "WARNING: sfdisk not found — partition module cannot see any disks."
    echo "         Install with: sudo apt-get install fdisk"
    echo ""
fi
if test -f "$LOOP_FILE" && sudo losetup "$(cat "$LOOP_FILE")" >/dev/null 2>&1; then
    LOOP_DEV=$(cat "$LOOP_FILE")
    echo "Block device details:"
    lsblk "$LOOP_DEV" 2>/dev/null || true
fi
