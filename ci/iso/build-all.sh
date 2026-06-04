#!/bin/bash
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Build esterOS Debian installer ISOs for amd64 and arm64.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRCDIR="${SRCDIR:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"

ARCHES="${ARCHES:-amd64 arm64}"

for arch in ${ARCHES}; do
    echo "========== Building ${arch} ISO =========="
    ARCH="${arch}" SRCDIR="${SRCDIR}" bash "${SCRIPT_DIR}/build.sh"
done

echo "All ISOs:"
ls -lh "${SRCDIR}/ci/iso/out/"*.iso 2>/dev/null || true
