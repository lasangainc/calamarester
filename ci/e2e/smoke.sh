#!/bin/sh
# Non-destructive smoke test: load Calamares UI and exit (no install).
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
SRCDIR=${SRCDIR:-$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)}
BUILDDIR=${BUILDDIR:-$SRCDIR/build}
DISPLAY_NUM=${CALAMARES_E2E_DISPLAY:-99}

if [ ! -x "$BUILDDIR/calamares" ]; then
    echo "! Build first: $SCRIPT_DIR/setup.sh"
    exit 1
fi

export DISPLAY=:${DISPLAY_NUM}
if ! pgrep -f "Xvfb :${DISPLAY_NUM}" >/dev/null 2>&1; then
    Xvfb ":${DISPLAY_NUM}" -screen 0 1280x720x24 &
    sleep 1
fi

cd "$BUILDDIR"
# Timeout prevents hanging if the window blocks; user can run run.sh for full UI.
timeout 25s ./calamares -d -D8 "$@" &
pid=$!
sleep 8
if kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
fi
echo "==> Smoke: calamares started under Xvfb (see log above for fatal errors)"
