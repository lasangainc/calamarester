#!/bin/sh
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Install GRUB arm64-efi modules on the build host when the distro
# package is unavailable (e.g. Ubuntu noble without grub-efi-arm64-bin).
set -eu

if test -d /usr/lib/grub/arm64-efi && test -f /usr/lib/grub/arm64-efi/modinfo.sh; then
    echo "host grub arm64-efi already present"
    exit 0
fi

if apt-get install -y grub-efi-arm64-bin 2>/dev/null; then
    exit 0
fi

GRUB_DEB_VER="${GRUB_DEB_VER:-2.06-13+deb12u2}"
DEB_URL="http://deb.debian.org/debian/pool/main/g/grub2/grub-efi-arm64-bin_${GRUB_DEB_VER}_arm64.deb"
TMP=$(mktemp -d)

echo "Fetching Debian grub-efi-arm64-bin for host ISO tooling..."
apt-get install -y wget
wget -q -O "${TMP}/grub-efi-arm64-bin.deb" "${DEB_URL}"
dpkg-deb -x "${TMP}/grub-efi-arm64-bin.deb" "${TMP}/extract"
install -d /usr/lib/grub
cp -a "${TMP}/extract/usr/lib/grub/arm64-efi" /usr/lib/grub/
rm -rf "${TMP}"
echo "Installed /usr/lib/grub/arm64-efi from Debian package"
