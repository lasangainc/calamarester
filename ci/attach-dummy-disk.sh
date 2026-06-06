#!/bin/bash
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Attach a loop-backed disk image for Calamares end-to-end testing.
# The image is wiped on each attach so the partition step can use "erase disk".
#
# Usage:
#   sudo ./ci/attach-dummy-disk.sh
#   CALAMARES_DUMMY_DISK_SIZE=32G sudo ./ci/attach-dummy-disk.sh

set -euo pipefail

BUILDDIR="${BUILDDIR:-/workspace/build}"
IMG="${CALAMARES_DUMMY_DISK_IMG:-$BUILDDIR/calamares-dummy-disk.img}"
STATE="${CALAMARES_DUMMY_DISK_STATE:-$BUILDDIR/calamares-dummy-disk.state}"
SIZE="${CALAMARES_DUMMY_DISK_SIZE:-20G}"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    exec sudo -E env BUILDDIR="$BUILDDIR" CALAMARES_DUMMY_DISK_IMG="$IMG" \
        CALAMARES_DUMMY_DISK_STATE="$STATE" CALAMARES_DUMMY_DISK_SIZE="$SIZE" "$0" "$@"
fi

mkdir -p "$BUILDDIR"

if [[ -f "$STATE" ]]; then
    # shellcheck disable=SC1090
    source "$STATE"
    if [[ -n "${LOOP_DEV:-}" ]] && losetup "${LOOP_DEV}" &>/dev/null; then
        echo "Dummy disk already attached: ${LOOP_DEV} -> ${IMG}"
        lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL "${LOOP_DEV}"
        exit 0
    fi
fi

echo "Creating ${SIZE} dummy disk image at ${IMG}"
truncate -s "${SIZE}" "${IMG}"

LOOP_DEV="$(losetup -f --show "${IMG}")"
partprobe "${LOOP_DEV}" 2>/dev/null || true
wipefs -a "${LOOP_DEV}" 2>/dev/null || true

cat >"${STATE}" <<EOF
LOOP_DEV=${LOOP_DEV}
IMG=${IMG}
SIZE=${SIZE}
EOF

echo "Attached dummy disk ${LOOP_DEV} (${SIZE})"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL "${LOOP_DEV}"
