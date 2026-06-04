# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Architecture selection for esterOS Debian ISO builds.
# Source from build scripts:  . "${SCRIPT_DIR}/arch.sh"; iso_arch_init
#
# Supported ARCH values: amd64, arm64

iso_arch_init() {
    ARCH="${ARCH:-amd64}"

    case "${ARCH}" in
        amd64)
            DEBIAN_ARCH=amd64
            KERNEL_PACKAGE=linux-image-amd64
            ISO_ARCH_SUFFIX=amd64
            QEMU_CPU=""
            GRUB_PLATFORM=pc
            GRUB_EFI_DIR=""
            ;;
        arm64|aarch64)
            ARCH=arm64
            DEBIAN_ARCH=arm64
            KERNEL_PACKAGE=linux-image-arm64
            ISO_ARCH_SUFFIX=arm64
            QEMU_CPU=aarch64
            GRUB_PLATFORM=efi
            GRUB_EFI_DIR=/usr/lib/grub/arm64-efi
            ;;
        *)
            echo "Unsupported ARCH=${ARCH} (use amd64 or arm64)" >&2
            return 1
            ;;
    esac

    HOST_ARCH="$(dpkg --print-architecture 2>/dev/null || true)"
    case "${HOST_ARCH}" in
        amd64) HOST_DEBIAN_ARCH=amd64 ;;
        arm64) HOST_DEBIAN_ARCH=arm64 ;;
        *) HOST_DEBIAN_ARCH="" ;;
    esac

    ISO_NEEDS_QEMU=false
    if test -n "${QEMU_CPU}" && test "${DEBIAN_ARCH}" != "${HOST_DEBIAN_ARCH}"; then
        ISO_NEEDS_QEMU=true
    fi

    export ARCH DEBIAN_ARCH KERNEL_PACKAGE ISO_ARCH_SUFFIX QEMU_CPU
    export GRUB_PLATFORM GRUB_EFI_DIR ISO_NEEDS_QEMU HOST_DEBIAN_ARCH
}

iso_arch_grub_mkrescue() {
    local out_iso=$1
    local iso_tree=$2

    if test -n "${GRUB_EFI_DIR}" && test -d "${GRUB_EFI_DIR}"; then
        grub-mkrescue -o "${out_iso}" --directory="${GRUB_EFI_DIR}" "${iso_tree}" -- -volid "ESTEROS_DEBIAN"
    else
        grub-mkrescue -o "${out_iso}" "${iso_tree}" -- -volid "ESTEROS_DEBIAN"
    fi
}

iso_arch_enable_binfmt() {
    test "${ISO_NEEDS_QEMU}" = true || return 0

    if test -f "/proc/sys/fs/binfmt_misc/qemu-${QEMU_CPU}"; then
        return 0
    fi

    mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc 2>/dev/null || true
    if test ! -w /proc/sys/fs/binfmt_misc/register 2>/dev/null; then
        echo "binfmt_misc unavailable; arm64 build needs qemu-user-binfmt" >&2
        return 1
    fi

    if test -f /usr/lib/binfmt.d/qemu-aarch64.conf; then
        grep -v '^#' /usr/lib/binfmt.d/qemu-aarch64.conf | while read -r line; do
            echo "$line" > /proc/sys/fs/binfmt_misc/register 2>/dev/null || true
        done
    fi
}

iso_arch_prepare_debootstrap() {
    local chroot=$1
    local suite=$2
    mkdir -p "${chroot}/usr/share/debootstrap"
    cp -a /usr/share/debootstrap/functions "${chroot}/usr/share/debootstrap/"
    cp -a /usr/share/debootstrap/scripts "${chroot}/usr/share/debootstrap/"
    if test -d "${chroot}/debootstrap"; then
        cp -a "${chroot}/debootstrap/." "${chroot}/usr/share/debootstrap/" 2>/dev/null || true
    fi
    if test ! -f "${chroot}/usr/share/debootstrap/suite"; then
        echo "${suite}" >"${chroot}/usr/share/debootstrap/suite"
    fi
}

iso_arch_mount_virtual_fs() {
    local root=$1
    mkdir -p "${root}/dev/pts" "${root}/proc" "${root}/sys"
    mountpoint -q "${root}/dev" || mount --bind /dev "${root}/dev"
    mountpoint -q "${root}/dev/pts" || mount --bind /dev/pts "${root}/dev/pts"
    mountpoint -q "${root}/proc" || mount -t proc proc "${root}/proc"
    mountpoint -q "${root}/sys" || mount -t sysfs sysfs "${root}/sys"
}

iso_arch_umount_virtual_fs() {
    local root=$1
    umount "${root}/dev/pts" 2>/dev/null || true
    umount "${root}/dev" 2>/dev/null || true
    umount "${root}/proc" 2>/dev/null || true
    umount "${root}/sys" 2>/dev/null || true
}

iso_arch_setup_qemu() {
    local chroot=$1
    test "${ISO_NEEDS_QEMU}" = true || return 0

    local qemu_bin="/usr/bin/qemu-${QEMU_CPU}-static"
    test -x "${qemu_bin}" || {
        echo "Missing ${qemu_bin} — install qemu-user-static" >&2
        return 1
    }
    install -D "${qemu_bin}" "${chroot}/usr/bin/qemu-${QEMU_CPU}-static"
    iso_arch_enable_binfmt
}

# Run a command in the target rootfs (native chroot or QEMU user emulation).
# The command must use an absolute guest path (e.g. /usr/bin/apt-get).
iso_arch_chroot() {
    local root=$1
    local prog=$2
    shift 2
    case "${prog}" in
        /*) ;;
        *)
            echo "iso_arch_chroot: program path must be absolute: ${prog}" >&2
            return 1
            ;;
    esac
    if test "${ISO_NEEDS_QEMU}" = true; then
        # Do not pass QEMU_CPU in the environment — qemu-user-static treats it
        # as a -cpu model and fails with "unable to find CPU model 'aarch64'".
        env -u QEMU_CPU chroot "${root}" "/usr/bin/qemu-${QEMU_CPU}-static" "${prog}" "$@"
    else
        chroot "${root}" "${prog}" "$@"
    fi
}
