# esterOS Debian installer ISO

Builds bootable **Debian bookworm** live ISOs that launch the customized **esterOS** Calamares installer to install Debian onto a target disk.

Supported architectures:

| `ARCH` | ISO output | Notes |
|--------|------------|--------|
| `amd64` (default) | `esteros-debian-bookworm-amd64.iso` | BIOS + UEFI hybrid |
| `arm64` | `esteros-debian-bookworm-arm64.iso` | UEFI (AArch64); built on x86 via QEMU user emulation |

## Requirements

- Ubuntu 24.04 (or similar) build host with **root/sudo**
- ~15 GiB free disk per architecture (~25 GiB for both)
- Network access to `deb.debian.org`
- **arm64 on x86:** `qemu-user-static` and `binfmt-support` (installed by `deps.sh`)

Install host dependencies:

```bash
sudo bash ci/iso/deps.sh
```

## Build

**amd64 only (default):**

```bash
export SRCDIR=/workspace
sudo bash ci/iso/build.sh
```

**arm64 (AArch64 / Raspberry Pi 4+, Apple Silicon VMs, ARM servers):**

```bash
export SRCDIR=/workspace
sudo ARCH=arm64 bash ci/iso/build.sh
```

**Both architectures:**

```bash
sudo bash ci/iso/build-all.sh
```

Outputs under `ci/iso/out/`:

- `esteros-debian-bookworm-amd64.iso` (+ `.sha256`)
- `esteros-debian-bookworm-arm64.iso` (+ `.sha256`)

Work directories are per-arch: `ci/iso/work/amd64/`, `ci/iso/work/arm64/`.

## Using the ISO

1. Write the ISO to USB or boot in a VM (**use the ISO matching your machine**: amd64 for PC/Mac Boot Camp x86, arm64 for AArch64).
2. Boot **esterOS Debian Installer (live)**.
3. Calamares starts automatically.
4. Partition the **target** disk (e.g. **Erase disk**) and complete the install.
5. Reboot into the installed system.

The installed system is Debian bookworm from the live rootfs; live-session packages and Calamares are removed during install (`packages` module).

## Configuration

| Path | Purpose |
|------|---------|
| `config/settings.conf` | Module sequence (Debian, no Arch `initcpio`) |
| `config/modules/unpackfs.conf` | Unpacks `live/filesystem.squashfs` from the medium |
| `config/modules/bootloader.conf` | GRUB with Debian EFI id |
| `config/modules/packages.conf` | Purge live-boot stack from target |
| `config/modules/users.conf` | Debian `sudo` group |
| `config/modules/displaymanager.conf` | lightdm on target |
| `arch.sh` | Architecture constants and GRUB/QEMU helpers |

Branding and QML modules come from the in-chroot Calamares build (`esteros` branding in `src/branding/esteros/`).

## Publish to GitHub Releases

Current release: [v1.0.0-esteros-debian-20260604](https://github.com/lasangainc/calamarester/releases/tag/v1.0.0-esteros-debian-20260604) (amd64 + arm64 assets).

```bash
gh release create "v1.0.0-esteros-debian-$(date +%Y%m%d)" \
  ci/iso/out/esteros-debian-bookworm-amd64.iso \
  ci/iso/out/esteros-debian-bookworm-amd64.iso.sha256 \
  ci/iso/out/esteros-debian-bookworm-arm64.iso \
  ci/iso/out/esteros-debian-bookworm-arm64.iso.sha256 \
  --repo lasangainc/calamarester \
  --title "esterOS Debian Installer ISO (amd64 + arm64)" \
  --notes "Debian bookworm live ISOs with esterOS Calamares."
```
