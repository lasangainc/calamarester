#!/bin/sh
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Launch Calamares in debug mode for esterOS UI walkthrough testing.
# Does not require root. Uses the build-tree settings.conf (branding: esteros).

set -eu

SRCDIR="${SRCDIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BUILDDIR="${BUILDDIR:-$SRCDIR/build}"
DISPLAY_NUM="${DISPLAY_NUM:-99}"
export DISPLAY=":${DISPLAY_NUM}"

if test ! -x "$BUILDDIR/calamares"; then
    echo "Calamares not built. Run: $SRCDIR/ci/e2e-setup.sh" >&2
    exit 1
fi

# Start Xvfb if not already running on this display
if ! xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
    echo "==> Starting Xvfb on $DISPLAY"
    Xvfb "$DISPLAY" -screen 0 1280x720x24 &
    XVFB_PID=$!
    trap 'kill "$XVFB_PID" 2>/dev/null || true' EXIT INT TERM
    sleep 1
fi

echo "==> Launching Calamares (esterOS UI walkthrough)"
echo "    Working directory: $BUILDDIR"
echo "    DISPLAY=$DISPLAY"
echo ""
echo "Navigate through: Welcome → Locale → Keyboard → Partition → Users → Summary"
echo "Press Ctrl+C to quit."
echo ""

cd "$BUILDDIR"
exec ./calamares -d
