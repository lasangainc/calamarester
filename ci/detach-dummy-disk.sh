#!/bin/bash
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Detach the loop-backed dummy disk created by attach-dummy-disk.sh.

set -euo pipefail

BUILDDIR="${BUILDDIR:-/workspace/build}"
STATE="${CALAMARES_DUMMY_DISK_STATE:-$BUILDDIR/calamares-dummy-disk.state}"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    exec sudo -E env BUILDDIR="$BUILDDIR" CALAMARES_DUMMY_DISK_STATE="$STATE" "$0" "$@"
fi

if [[ ! -f "$STATE" ]]; then
    echo "No dummy disk state file at ${STATE}"
    exit 0
fi

# shellcheck disable=SC1090
source "$STATE"

if [[ -n "${LOOP_DEV:-}" ]] && losetup "${LOOP_DEV}" &>/dev/null; then
    losetup -d "${LOOP_DEV}"
    echo "Detached ${LOOP_DEV}"
else
    echo "Loop device ${LOOP_DEV:-<unknown>} is not attached"
fi

rm -f "$STATE"
