#!/bin/bash
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Configure the Debian root filesystem inside the ISO build chroot.
set -euo pipefail

CHROOT="${1:?chroot path required}"
ISO_CONFIG="${2:?iso config directory required}"

export DEBIAN_FRONTEND=noninteractive

# Debian archive inside the chroot
cat >"${CHROOT}/etc/apt/sources.list" <<'EOF'
deb http://deb.debian.org/debian bookworm main contrib non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free-firmware
EOF

chroot "${CHROOT}" apt-get update
chroot "${CHROOT}" apt-get install -y --no-install-recommends \
    linux-image-amd64 \
    live-boot \
    live-config \
    live-config-systemd \
    live-tools \
    systemd-sysv \
    network-manager \
    sudo \
    bash-completion \
    locales \
    ca-certificates \
    dbus \
    polkitd \
    pkexec \
    parted \
    gdisk \
    dosfstools \
    e2fsprogs \
    btrfs-progs \
    xfsprogs \
    f2fs-tools \
    ntfs-3g \
    cryptsetup \
    lvm2 \
    grub-common \
    grub2-common \
    grub-pc-bin \
    grub-efi-amd64-bin \
    grub-efi-amd64-signed \
    shim-signed \
    os-prober \
    lightdm \
    xorg \
    xinit \
    openbox \
    xterm \
    fonts-dejavu \
    fontconfig \
    libqt5gui5 \
    libqt5widgets5 \
    libqt5svg5 \
    libqt5qml5 \
    libqt5quick5 \
    libqt5quickcontrols2-5 \
    libqt5webengine5 \
    qml-module-qtquick2 \
    qml-module-qtquick-controls2 \
    qml-module-qtquick-layouts \
    qml-module-qtquick-window2 \
    qml-module-qtquick-privatewidgets \
    libkf5configcore5 \
    libkf5configgui5 \
    libkf5coreaddons5 \
    libkf5i18n5 \
    libkf5iconthemes5 \
    libkf5service5 \
    libkf5solid5 \
    libkf5parts5 \
    libkf5kiocore5 \
    libkf5kiogui5 \
    libkf5kiowidgets5 \
    libkf5kiofilewidgets5 \
    libkf5crash5 \
    libkf5plasma5 \
    libkpmcore12 \
    libparted2 \
    libpolkit-qt5-1-1 \
    libpwquality1 \
    libyaml-cpp0.7 \
    python3 \
    python3-yaml \
    python3-dbus \
    python3-apt \
    rsync \
    squashfs-tools \
    efibootmgr \
    initramfs-tools

# Locale for Calamares and the installed system
chroot "${CHROOT}" sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
chroot "${CHROOT}" locale-gen en_US.UTF-8
echo 'LANG=en_US.UTF-8' >"${CHROOT}/etc/locale.conf"
echo 'LANG=en_US.UTF-8' >"${CHROOT}/etc/default/locale"

# ISO-specific Calamares configuration (installed after in-chroot Calamares build)
install -d "${CHROOT}/etc/calamares/modules"
install -m 644 "${ISO_CONFIG}/settings.conf" "${CHROOT}/etc/calamares/settings.conf"
cp -a "${ISO_CONFIG}/modules/." "${CHROOT}/etc/calamares/modules/"

# Launch Calamares automatically in the live session
install -d "${CHROOT}/etc/xdg/autostart"
cat >"${CHROOT}/etc/xdg/autostart/calamares.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=esterOS Installer
Comment=Install esterOS (Debian) to disk
Exec=/usr/bin/calamares
Icon=calamares
Terminal=false
Categories=System;
X-GNOME-Autostart-enabled=true
EOF

# Openbox session for the live environment
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

# LightDM auto-login as live user (created by live-config on first boot)
mkdir -p "${CHROOT}/etc/lightdm/lightdm.conf.d"
cat >"${CHROOT}/etc/lightdm/lightdm.conf.d/99-live.conf" <<'EOF'
[Seat:*]
autologin-user=live
autologin-user-timeout=0
user-session=openbox
EOF

# live-config: hostname and username for the live session
mkdir -p "${CHROOT}/etc/live/config.conf.d"
cat >"${CHROOT}/etc/live/config.conf.d/esteros.conf" <<'EOF'
LIVE_HOSTNAME="esteros-live"
LIVE_USERNAME="live"
LIVE_USER_FULLNAME="esterOS Live"
LIVE_USER_DEFAULT_GROUPS="audio cdrom dip floppy video plugdev netdev sudo"
EOF

# Polkit: allow live user to run calamares as root via pkexec if needed
cat >"${CHROOT}/etc/polkit-1/rules.d/49-calamares-live.rules" <<'EOF'
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.policykit.exec") == 0 &&
        subject.isInGroup("sudo")) {
        return polkit.Result.YES;
    }
});
EOF

# Run calamares as root in live (installer needs full privileges)
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

chroot "${CHROOT}" apt-get clean
rm -rf "${CHROOT}/var/lib/apt/lists/"*
