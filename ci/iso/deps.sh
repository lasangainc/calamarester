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
    grub-efi-arm64-bin \
    qemu-user-static \
    binfmt-support \
    mtools \
    dosfstools \
    rsync

# Calamares build dependencies (Ubuntu host building Debian rootfs)
if test -f /workspace/ci/deps-ubuntu.sh; then
    bash /workspace/ci/deps-ubuntu.sh
fi

apt-get install -y ninja-build g++ libstdc++-12-dev
