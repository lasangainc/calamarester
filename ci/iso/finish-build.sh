#!/bin/bash
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Resume ISO build after Calamares is already built in the chroot.
# Set ARCH=amd64 (default) or ARCH=arm64.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=arch.sh
. "${SCRIPT_DIR}/arch.sh"
iso_arch_init
export ARCH DEBIAN_ARCH KERNEL_PACKAGE ISO_ARCH_SUFFIX

SRCDIR="${SRCDIR:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"
ISO_WORK="${ISO_WORK:-${SRCDIR}/ci/iso/work/${ARCH}}"
ISO_OUT="${ISO_OUT:-${SRCDIR}/ci/iso/out}"
ISO_CONFIG="${SCRIPT_DIR}/config"
CHROOT="${ISO_WORK}/chroot"
ISO_TREE="${ISO_WORK}/iso-tree"
SQUASHFS="${ISO_TREE}/live/filesystem.squashfs"
DEBIAN_SUITE="${DEBIAN_SUITE:-bookworm}"
ISO_NAME="${ISO_NAME:-esteros-debian-${DEBIAN_SUITE}-${ISO_ARCH_SUFFIX}.iso}"

log() { printf '==> [%s] %s\n' "${ARCH}" "$*"; }

test "$(id -u)" -eq 0 || { echo "run as root"; exit 1; }
test -x "${CHROOT}/usr/bin/calamares" || { echo "missing ${CHROOT}/usr/bin/calamares"; exit 1; }

log "Configuring root filesystem"
bash "${SCRIPT_DIR}/chroot-setup.sh" "${CHROOT}" "${ISO_CONFIG}"

log "Creating squashfs image"
rm -rf "${ISO_TREE}"
mkdir -p "${ISO_TREE}/live" "${ISO_TREE}/boot/grub"
mksquashfs "${CHROOT}" "${SQUASHFS}" -comp zstd -Xcompression-level 6 -noappend -e boot

kernel="$(ls "${CHROOT}/boot"/vmlinuz-* 2>/dev/null | sort -V | tail -n1)"
initrd="$(ls "${CHROOT}/boot"/initrd.img-* 2>/dev/null | sort -V | tail -n1)"
cp "${kernel}" "${ISO_TREE}/live/vmlinuz"
cp "${initrd}" "${ISO_TREE}/live/initrd.img"

cat >"${ISO_TREE}/boot/grub/grub.cfg" <<'EOF'
set default=0
set timeout=5

menuentry "esterOS Debian Installer (live)" {
    linux /live/vmlinuz boot=live components quiet splash ---
    initrd /live/initrd.img
}

menuentry "esterOS Debian Installer (live, safe graphics)" {
    linux /live/vmlinuz boot=live components nomodeset quiet ---
    initrd /live/initrd.img
}
EOF

mkdir -p "${ISO_OUT}"
out_iso="${ISO_OUT}/${ISO_NAME}"
rm -f "${out_iso}"
log "Building ISO"
iso_arch_grub_mkrescue "${out_iso}" "${ISO_TREE}"
sha256sum "${out_iso}" | tee "${out_iso}.sha256"
log "Done: ${out_iso}"
