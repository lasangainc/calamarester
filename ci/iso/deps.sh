#!/bin/sh
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Host packages required to build the esterOS Debian installer ISO.
set -eu

apt-get update
apt-get install -y \
    debian-archive-keyring \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    qemu-user-static \
    qemu-user-binfmt \
    binfmt-support \
    mtools \
    dosfstools \
    rsync

# Calamares build dependencies (Ubuntu host building Debian rootfs)
if test -f /workspace/ci/deps-ubuntu.sh; then
    bash /workspace/ci/deps-ubuntu.sh
fi

apt-get install -y ninja-build g++ libstdc++-12-dev

# Host grub arm64-efi modules (for grub-mkrescue arm64 ISOs on x86)
bash "$(dirname "$0")/install-host-grub-arm64.sh"

# Optional: register binfmt for arm64 (speeds up some tools; chroot uses qemu-static).
mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc 2>/dev/null || true
if test -w /proc/sys/fs/binfmt_misc/register && test -f /usr/lib/binfmt.d/qemu-aarch64.conf; then
    grep -v '^#' /usr/lib/binfmt.d/qemu-aarch64.conf | while read -r line; do
        echo "$line" > /proc/sys/fs/binfmt_misc/register 2>/dev/null || true
    done
fi
