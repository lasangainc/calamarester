#!/bin/bash
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Configure the Debian root filesystem inside the ISO build chroot.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=arch.sh
. "${SCRIPT_DIR}/arch.sh"
# shellcheck source=chroot-packages.sh
. "${SCRIPT_DIR}/chroot-packages.sh"
iso_arch_init
export ARCH DEBIAN_ARCH KERNEL_PACKAGE ISO_NEEDS_QEMU QEMU_CPU

CHROOT="${1:?chroot path required}"
ISO_CONFIG="${2:?iso config directory required}"

export DEBIAN_FRONTEND=noninteractive

iso_arch_mount_virtual_fs "${CHROOT}"

cat >"${CHROOT}/etc/apt/sources.list" <<'EOF'
deb http://deb.debian.org/debian bookworm main contrib non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free-firmware
EOF

iso_arch_chroot "${CHROOT}" /usr/bin/apt-get update

mapfile -t chroot_packages < <(iso_chroot_packages)
iso_arch_chroot "${CHROOT}" /usr/bin/apt-get install -y --no-install-recommends "${chroot_packages[@]}"

# Locale for Calamares and the installed system
iso_arch_chroot "${CHROOT}" /bin/sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
iso_arch_chroot "${CHROOT}" /usr/sbin/locale-gen en_US.UTF-8
echo 'LANG=en_US.UTF-8' >"${CHROOT}/etc/locale.conf"
echo 'LANG=en_US.UTF-8' >"${CHROOT}/etc/default/locale"

# ISO-specific Calamares configuration (installed after in-chroot Calamares build)
install -d "${CHROOT}/etc/calamares/modules"
install -m 644 "${ISO_CONFIG}/settings.conf" "${CHROOT}/etc/calamares/settings.conf"
cp -a "${ISO_CONFIG}/modules/." "${CHROOT}/etc/calamares/modules/"

install -d "${CHROOT}/etc/xdg/autostart"
install -d "${CHROOT}/etc/xdg/openbox"
cat >"${CHROOT}/etc/xdg/openbox/rc.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <theme><name>Clearlooks</name></theme>
</openbox_config>
EOF

cat >"${CHROOT}/etc/xdg/openbox/autostart" <<'EOF'
#!/bin/sh
xset s off
xset -dpms
xset s noblank
EOF
chmod +x "${CHROOT}/etc/xdg/openbox/autostart"

mkdir -p "${CHROOT}/etc/lightdm/lightdm.conf.d"
cat >"${CHROOT}/etc/lightdm/lightdm.conf.d/99-live.conf" <<'EOF'
[Seat:*]
autologin-user=live
autologin-user-timeout=0
user-session=openbox
EOF

mkdir -p "${CHROOT}/etc/live/config.conf.d"
cat >"${CHROOT}/etc/live/config.conf.d/esteros.conf" <<'EOF'
LIVE_HOSTNAME="esteros-live"
LIVE_USERNAME="live"
LIVE_USER_FULLNAME="esterOS Live"
LIVE_USER_DEFAULT_GROUPS="audio cdrom dip floppy video plugdev netdev sudo"
EOF

cat >"${CHROOT}/etc/polkit-1/rules.d/49-calamares-live.rules" <<'EOF'
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.policykit.exec") == 0 &&
        subject.isInGroup("sudo")) {
        return polkit.Result.YES;
    }
});
EOF

cat >"${CHROOT}/etc/xdg/autostart/calamares.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=esterOS Installer
Comment=Install esterOS (Debian) to disk
Exec=pkexec calamares
Icon=calamares
Terminal=false
Categories=System;
X-GNOME-Autostart-enabled=true
EOF

iso_arch_chroot "${CHROOT}" /usr/bin/apt-get clean
rm -rf "${CHROOT}/var/lib/apt/lists/"*

iso_arch_umount_virtual_fs "${CHROOT}"
