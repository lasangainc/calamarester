# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Print arch-specific apt package lists (one package per line).
# Usage: . arch.sh && iso_arch_init && . chroot-packages.sh && iso_chroot_packages

iso_chroot_packages_common() {
    cat <<'EOF'
live-boot
live-config
live-config-systemd
live-tools
systemd-sysv
network-manager
sudo
bash-completion
locales
ca-certificates
dbus
polkitd
pkexec
parted
gdisk
dosfstools
e2fsprogs
btrfs-progs
xfsprogs
f2fs-tools
ntfs-3g
cryptsetup
lvm2
grub-common
grub2-common
os-prober
lightdm
xorg
xinit
openbox
xterm
fonts-dejavu
fontconfig
libqt5gui5
libqt5widgets5
libqt5svg5
libqt5qml5
libqt5quick5
libqt5quickcontrols2-5
libqt5webengine5
qml-module-qtquick2
qml-module-qtquick-controls2
qml-module-qtquick-layouts
qml-module-qtquick-window2
qml-module-qtquick-privatewidgets
libkf5configcore5
libkf5configgui5
libkf5coreaddons5
libkf5i18n5
libkf5iconthemes5
libkf5service5
libkf5solid5
libkf5parts5
libkf5kiocore5
libkf5kiogui5
libkf5kiowidgets5
libkf5kiofilewidgets5
libkf5crash5
libkf5plasma5
libkpmcore12
libparted2
libpolkit-qt5-1-1
libpwquality1
libyaml-cpp0.7
python3
python3-yaml
python3-dbus
python3-apt
rsync
squashfs-tools
efibootmgr
initramfs-tools
EOF
}

iso_chroot_packages_arch() {
    echo "${KERNEL_PACKAGE}"
    case "${ARCH}" in
        amd64)
            cat <<'EOF'
grub-pc-bin
grub-efi-amd64-bin
grub-efi-amd64-signed
shim-signed
EOF
            ;;
        arm64)
            cat <<'EOF'
grub-efi-arm64-bin
grub-efi-arm64-signed
EOF
            ;;
    esac
}

iso_chroot_packages() {
    iso_chroot_packages_common
    iso_chroot_packages_arch
}
