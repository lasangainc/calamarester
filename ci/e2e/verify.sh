#!/bin/sh
# Quick post-install checks on the E2E target disk (run after a successful install).
set -eu

E2E_DISK=${CALAMARES_E2E_DISK:-/dev/vdb}

if [ ! -b "$E2E_DISK" ]; then
    echo "! Block device $E2E_DISK not found"
    exit 1
fi

echo "==> Partition layout on $E2E_DISK"
lsblk -o NAME,TYPE,FSTYPE,SIZE,MOUNTPOINT "$E2E_DISK" || true

ROOT_PART=""
for p in "${E2E_DISK}"*; do
    [ -b "$p" ] || continue
    fstype=$(blkid -o value -s TYPE "$p" 2>/dev/null || true)
    if [ "$fstype" = "ext4" ] || [ "$fstype" = "btrfs" ] || [ "$fstype" = "xfs" ]; then
        ROOT_PART=$p
        break
    fi
done

if [ -z "$ROOT_PART" ]; then
    echo "! No obvious root filesystem partition found on $E2E_DISK"
    exit 1
fi

echo "==> Checking root filesystem on $ROOT_PART"
if command -v sudo >/dev/null 2>&1 && [ "$(id -u)" -ne 0 ]; then
    SUDO=sudo
else
    SUDO=
fi

MNT=$(mktemp -d)
cleanup() { $SUDO umount "$MNT" 2>/dev/null || true; rmdir "$MNT" 2>/dev/null || true; }
trap cleanup EXIT

$SUDO mount "$ROOT_PART" "$MNT"
for f in etc/issue bin/sh usr/bin/env; do
    if [ -e "$MNT/$f" ]; then
        echo "  ok: /$f"
    else
        echo "  missing: /$f"
        exit 1
    fi
done

if [ -f "$MNT/boot/grub/grub.cfg" ]; then
    echo "  ok: /boot/grub/grub.cfg"
else
    echo "  warn: no /boot/grub/grub.cfg (bootloader step may have been skipped)"
fi

echo "==> E2E verification passed on $ROOT_PART"
