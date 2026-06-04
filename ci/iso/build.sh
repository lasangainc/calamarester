#!/bin/bash
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Build a bootable Debian ISO with the customized esterOS Calamares installer.
# Set ARCH=amd64 (default) or ARCH=arm64.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=arch.sh
. "${SCRIPT_DIR}/arch.sh"
iso_arch_init
export ARCH DEBIAN_ARCH KERNEL_PACKAGE ISO_ARCH_SUFFIX ISO_NEEDS_QEMU QEMU_CPU

SRCDIR="${SRCDIR:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"
BUILDDIR="${BUILDDIR:-${SRCDIR}/build}"
ISO_WORK="${ISO_WORK:-${SRCDIR}/ci/iso/work/${ARCH}}"
ISO_OUT="${ISO_OUT:-${SRCDIR}/ci/iso/out}"
ISO_CONFIG="${SCRIPT_DIR}/config"
DEBIAN_SUITE="${DEBIAN_SUITE:-bookworm}"
DEBIAN_MIRROR="${DEBIAN_MIRROR:-http://deb.debian.org/debian}"
ISO_NAME="${ISO_NAME:-esteros-debian-${DEBIAN_SUITE}-${ISO_ARCH_SUFFIX}.iso}"
CHROOT="${ISO_WORK}/chroot"
ISO_TREE="${ISO_WORK}/iso-tree"
SQUASHFS="${ISO_TREE}/live/filesystem.squashfs"

log() { printf '==> [%s] %s\n' "${ARCH}" "$*"; }

require_root() {
    if test "$(id -u)" -ne 0; then
        echo "This script must run as root (sudo)." >&2
        exit 1
    fi
}

build_calamares_in_chroot() {
    log "Building Calamares inside Debian chroot"
    export ARCH DEBIAN_ARCH ISO_NEEDS_QEMU QEMU_CPU
    bash "${SCRIPT_DIR}/build-calamares-chroot.sh" "${CHROOT}" "${SRCDIR}"
}

bootstrap_rootfs() {
    log "Bootstrapping Debian ${DEBIAN_SUITE} (${DEBIAN_ARCH})"
    rm -rf "${CHROOT}"
    mkdir -p "${CHROOT}"

    local debootstrap_args=(
        --arch="${DEBIAN_ARCH}"
        --variant=minbase
        --include=systemd,systemd-sysv,apt,ca-certificates,locales,sudo
    )

    if test "${ISO_NEEDS_QEMU}" = true; then
        debootstrap "${debootstrap_args[@]}" --foreign \
            "${DEBIAN_SUITE}" "${CHROOT}" "${DEBIAN_MIRROR}"
        iso_arch_setup_qemu "${CHROOT}"
        if command -v update-binfmts >/dev/null 2>&1; then
            update-binfmts --enable "qemu-${QEMU_CPU}" 2>/dev/null || true
        fi
        chroot "${CHROOT}" /debootstrap/debootstrap --second-stage
    else
        debootstrap "${debootstrap_args[@]}" \
            "${DEBIAN_SUITE}" "${CHROOT}" "${DEBIAN_MIRROR}"
    fi

    if test "${ISO_NEEDS_QEMU}" = true; then
        iso_arch_setup_qemu "${CHROOT}"
    fi
}

configure_rootfs() {
    log "Configuring root filesystem"
    export ARCH DEBIAN_ARCH KERNEL_PACKAGE
    build_calamares_in_chroot
    bash "${SCRIPT_DIR}/chroot-setup.sh" "${CHROOT}" "${ISO_CONFIG}"
}

create_squashfs() {
    log "Creating squashfs image"
    rm -rf "${ISO_TREE}"
    mkdir -p "${ISO_TREE}/live" "${ISO_TREE}/boot/grub"
    mksquashfs "${CHROOT}" "${SQUASHFS}" -comp zstd -Xcompression-level 6 -noappend -e boot
}

install_kernel_initrd() {
    log "Copying kernel and initrd"
    kernel="$(ls "${CHROOT}/boot"/vmlinuz-* 2>/dev/null | sort -V | tail -n1)"
    initrd="$(ls "${CHROOT}/boot"/initrd.img-* 2>/dev/null | sort -V | tail -n1)"
    test -n "${kernel}" && test -n "${initrd}"
    cp "${kernel}" "${ISO_TREE}/live/vmlinuz"
    cp "${initrd}" "${ISO_TREE}/live/initrd.img"
}

write_grub_cfg() {
    log "Writing GRUB configuration"
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
}

build_iso() {
    log "Building ISO image"
    mkdir -p "${ISO_OUT}"
    out_iso="${ISO_OUT}/${ISO_NAME}"
    rm -f "${out_iso}"
    iso_arch_grub_mkrescue "${out_iso}" "${ISO_TREE}"
    log "ISO written to ${out_iso}"
    sha256sum "${out_iso}" | tee "${out_iso}.sha256"
}

main() {
    require_root
    mkdir -p "${ISO_WORK}" "${ISO_OUT}"

    if test "${ISO_NEEDS_QEMU}" = true; then
        log "Cross-arch build: host=${HOST_DEBIAN_ARCH:-?} target=${DEBIAN_ARCH} (QEMU user emulation)"
    fi

    bootstrap_rootfs
    configure_rootfs
    create_squashfs
    install_kernel_initrd
    write_grub_cfg
    build_iso
    log "Done: ${out_iso}"
}

main "$@"
