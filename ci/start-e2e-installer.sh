#!/bin/bash
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Prepare and launch Calamares for an end-to-end install test:
#   - attach loop-backed dummy disk
#   - build example.sqfs payload if missing
#   - run Calamares as root in dev mode on the desktop display

set -euo pipefail

SRCDIR="${SRCDIR:-/workspace}"
BUILDDIR="${BUILDDIR:-/workspace/build}"
DISPLAY="${DISPLAY:-:1}"

export SRCDIR BUILDDIR

if [[ ! -x "${BUILDDIR}/calamares" ]]; then
    echo "Calamares binary not found at ${BUILDDIR}/calamares — build first." >&2
    exit 1
fi

if ! command -v sfdisk >/dev/null 2>&1; then
    echo "Installing fdisk (provides sfdisk for KPMcore device scanning) ..."
    sudo apt-get install -y fdisk
fi

"${SRCDIR}/ci/attach-dummy-disk.sh"

if [[ ! -f "${BUILDDIR}/example.sqfs" ]]; then
    echo "Building example.sqfs (ninja example-distro) ..."
    ninja -C "${BUILDDIR}" example-distro
fi

if pgrep -x calamares >/dev/null; then
    echo "Stopping existing Calamares instance ..."
    pkill -x calamares || true
    sleep 1
fi

echo "Starting Calamares on DISPLAY=${DISPLAY} (root, dev mode) ..."
exec sudo -E env DISPLAY="${DISPLAY}" SRCDIR="${SRCDIR}" BUILDDIR="${BUILDDIR}" \
    "${BUILDDIR}/calamares" -d
