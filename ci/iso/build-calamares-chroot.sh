#!/bin/bash
# SPDX-FileCopyrightText: no
# SPDX-License-Identifier: CC0-1.0
#
# Compile and install Calamares inside the Debian ISO chroot.
set -euo pipefail

CHROOT="${1:?chroot path required}"
SRCDIR="${2:?source directory required}"

export DEBIAN_FRONTEND=noninteractive

chroot "${CHROOT}" apt-get update
chroot "${CHROOT}" apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    extra-cmake-modules \
    gettext \
    ninja-build \
    pkg-config \
    libappstreamqt-dev \
    libkf5config-dev \
    libkf5coreaddons-dev \
    libkf5crash-dev \
    libkf5i18n-dev \
    libkf5iconthemes-dev \
    libkf5kio-dev \
    libkf5parts-dev \
    libkf5plasma-dev \
    libkf5service-dev \
    libkf5solid-dev \
    libkpmcore-dev \
    libparted-dev \
    libpolkit-qt5-1-dev \
    libpwquality-dev \
    libqt5svg5-dev \
    libqt5webkit5-dev \
    libyaml-cpp-dev \
    qtbase5-dev \
    qtdeclarative5-dev \
    qtlocation5-dev \
    qttools5-dev \
    qttools5-dev-tools \
    python3-dev \
    python3-yaml \
    python3-jsonschema \
    qml-module-qtquick-layouts \
    qml-module-qtquick-privatewidgets \
    qml-module-qtquick-window2 \
    qml-module-qtquick2

rsync -a \
    --exclude=.git \
    --exclude=build \
    --exclude=ci/iso/work \
    "${SRCDIR}/" "${CHROOT}/root/calamares-src/"

chroot "${CHROOT}" env \
    CC=gcc CXX=g++ \
    cmake -S /root/calamares-src -B /root/calamares-build -G Ninja \
        -DKDE_INSTALL_USE_QT_SYS_PATHS=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_TESTING=OFF \
        -DBUILD_SCHEMA_TESTING=OFF

chroot "${CHROOT}" ninja -C /root/calamares-build
chroot "${CHROOT}" ninja -C /root/calamares-build install

chroot "${CHROOT}" rm -rf /root/calamares-src /root/calamares-build
chroot "${CHROOT}" apt-get purge -y --auto-remove \
    build-essential cmake extra-cmake-modules ninja-build pkg-config \
    libappstreamqt-dev libkf5config-dev libkf5coreaddons-dev \
    libkf5crash-dev libkf5i18n-dev libkf5iconthemes-dev libkf5kio-dev \
    libkf5parts-dev libkf5plasma-dev libkf5service-dev libkf5solid-dev \
    libkpmcore-dev libparted-dev libpolkit-qt5-1-dev libpwquality-dev \
    libqt5svg5-dev libqt5webkit5-dev libyaml-cpp-dev qtbase5-dev \
    qtdeclarative5-dev qtlocation5-dev qttools5-dev qttools5-dev-tools \
    python3-dev || true
chroot "${CHROOT}" apt-get autoremove -y || true
