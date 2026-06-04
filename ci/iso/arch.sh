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
    # Usage: iso_arch_grub_mkrescue <output.iso> <iso-tree-dir>
    local out_iso=$1
    local iso_tree=$2

    if test -n "${GRUB_EFI_DIR}" && test -d "${GRUB_EFI_DIR}"; then
        grub-mkrescue -o "${out_iso}" --directory="${GRUB_EFI_DIR}" "${iso_tree}" -- -volid "ESTEROS_DEBIAN"
    else
        grub-mkrescue -o "${out_iso}" "${iso_tree}" -- -volid "ESTEROS_DEBIAN"
    fi
}

iso_arch_prepare_debootstrap() {
    local chroot=$1
    local suite=$2
    mkdir -p "${chroot}/usr/share/debootstrap"
    cp -a /usr/share/debootstrap/functions "${chroot}/usr/share/debootstrap/"
    cp -a /usr/share/debootstrap/scripts "${chroot}/usr/share/debootstrap/"
    if test -f "${chroot}/debootstrap/suite"; then
        cp "${chroot}/debootstrap/suite" "${chroot}/usr/share/debootstrap/suite"
    else
        echo "${suite}" >"${chroot}/usr/share/debootstrap/suite"
    fi
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
    iso_arch_enable_binfmt "${qemu_bin}"
}

iso_arch_enable_binfmt() {
    local qemu_bin="${1:-/usr/bin/qemu-${QEMU_CPU}-static}"
    test "${ISO_NEEDS_QEMU}" = true || return 0

    if test -f "/proc/sys/fs/binfmt_misc/qemu-${QEMU_CPU}"; then
        return 0
    fi
    if test ! -w /proc/sys/fs/binfmt_misc/register 2>/dev/null; then
        log_msg="binfmt_misc unavailable; using QEMU_LD_PREFIX for chroot commands"
        echo "${log_msg}" >&2
        return 0
    fi

    case "${QEMU_CPU}" in
        aarch64)
            printf '%s\n' \
                ":qemu-aarch64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xaa\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff:${qemu_bin}:F" \
                >/proc/sys/fs/binfmt_misc/register 2>/dev/null || true
            ;;
    esac
}

# Run a command in the target rootfs (native chroot or QEMU user emulation).
# The command must use an absolute guest path (e.g. /usr/bin/apt-get).
iso_arch_chroot() {
    local root=$1
    local prog=$2
    shift 2
    if test "${ISO_NEEDS_QEMU}" = true; then
        case "${prog}" in
            /*) ;;
            *)
                echo "iso_arch_chroot: program path must be absolute: ${prog}" >&2
                return 1
                ;;
        esac
        /usr/bin/qemu-${QEMU_CPU}-static -cpu max -L "${root}" "${root}${prog}" "$@"
    else
        chroot "${root}" "${prog}" "$@"
    fi
}
