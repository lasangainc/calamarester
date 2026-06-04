#!/bin/sh
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Detach the loopback test disk created by e2e-setup.sh.

set -eu

SRCDIR="${SRCDIR:-$(cd "$(dirname "$0")/.." && pwd)}"
E2EDIR="$SRCDIR/e2e"
LOOP_FILE="$E2EDIR/.loop-device"

if test -f "$LOOP_FILE"; then
    LOOP_DEV=$(cat "$LOOP_FILE")
    if sudo losetup "$LOOP_DEV" >/dev/null 2>&1; then
        echo "==> Detaching $LOOP_DEV"
        sudo losetup -d "$LOOP_DEV"
    fi
    rm -f "$LOOP_FILE"
    echo "Loop device detached. Disk image kept at $E2EDIR/target-disk.img"
else
    echo "No loop device registered (nothing to do)."
fi
