# esterOS Debian installer ISO

Builds a bootable **Debian bookworm** amd64 ISO that boots a live session and launches the customized **esterOS** Calamares installer to install Debian onto a target disk.

## Requirements

- Ubuntu 24.04 (or similar) build host with **root/sudo**
- ~15 GiB free disk space
- Network access to `deb.debian.org`

Install host dependencies:

```bash
sudo bash ci/iso/deps.sh
```

## Build

```bash
export SRCDIR=/workspace
export BUILDDIR=/workspace/build
sudo bash ci/iso/build.sh
```

Output:

- `ci/iso/out/esteros-debian-bookworm-amd64.iso`
- `ci/iso/out/esteros-debian-bookworm-amd64.iso.sha256`

## Using the ISO

1. Write the ISO to a USB stick (e.g. `dd`, Ventoy, Rufus) or boot it in a VM.
2. Boot **esterOS Debian Installer (live)**.
3. Calamares starts automatically and walks through welcome → locale → keyboard → partition → users → install.
4. Choose **Erase disk** (or manual partitioning) on the **target** drive only.
5. Reboot into the installed system when finished.

The installed system is Debian bookworm with packages from the live rootfs; live-session packages and Calamares are removed during install (`packages` module).

## Configuration

| Path | Purpose |
|------|---------|
| `config/settings.conf` | Module sequence (Debian, no Arch `initcpio`) |
| `config/modules/unpackfs.conf` | Unpacks `live/filesystem.squashfs` from the medium |
| `config/modules/bootloader.conf` | GRUB with Debian EFI id |
| `config/modules/packages.conf` | Purge live-boot stack from target |
| `config/modules/users.conf` | Debian `sudo` group |
| `config/modules/displaymanager.conf` | lightdm on target |

Branding and QML modules come from the Calamares build (`esteros` branding in `src/branding/esteros/`).

## Publish to GitHub Releases

```bash
gh release create "v1.0.0-esteros-debian-$(date +%Y%m%d)" \
  ci/iso/out/esteros-debian-bookworm-amd64.iso \
  ci/iso/out/esteros-debian-bookworm-amd64.iso.sha256 \
  --repo lasangainc/calamarester \
  --title "esterOS Debian Installer ISO" \
  --notes "Debian bookworm amd64 live ISO with esterOS Calamares."
```
