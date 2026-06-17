#!/bin/sh
# Extra packages for end-to-end installer testing on Ubuntu (BIOS/legacy VM).
set -eu

apt-get install -y \
    grub-pc-bin \
    grub-common \
    efibootmgr \
    dosfstools \
    xvfb \
    xauth \
    polkitd \
    rsync \
    arch-install-scripts
