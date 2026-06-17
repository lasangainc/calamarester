# End-to-end Calamares testing

This directory sets up a **full installer run** of Calamares on a dedicated spare disk, using the upstream **example Generic** root filesystem (`example.sqfs`).

## What you get

| Step | Script | Purpose |
|------|--------|---------|
| Setup | `./ci/e2e/setup.sh` | Install deps, build `calamares`, build `example.sqfs` |
| Smoke | `./ci/e2e/smoke.sh` | Headless UI launch (no install, non-destructive) |
| E2E | `./ci/e2e/run.sh` | Interactive installer on `$CALAMARES_E2E_DISK` |
| Verify | `./ci/e2e/verify.sh` | Mount target root and sanity-check files |

## Requirements

- Ubuntu 24.04 (or run `ci/deps-ubuntu.sh` on a similar distro)
- **Root/sudo** for partitioning, mount, and bootloader jobs
- A **spare whole disk** that may be erased (see below)
- **Xvfb** for headless GUI (installed by `deps.sh`)

### Target disk on Cursor Cloud

This VM typically has:

- `/dev/vda` — system disk (do **not** use for E2E)
- `/dev/vdb` — spare 256 GiB disk (default `CALAMARES_E2E_DISK`)

```bash
export CALAMARES_E2E_DISK=/dev/vdb   # default in run.sh
```

**Warning:** In the partition step, choose **Erase disk** on that device only. All data on `vdb` is destroyed.

## Quick start

```bash
cd /workspace
./ci/e2e/setup.sh
./ci/e2e/smoke.sh          # optional: confirm UI loads
sudo ./ci/e2e/run.sh       # interactive E2E install
sudo ./ci/e2e/verify.sh    # after success
```

`setup.sh` copies E2E settings into `$BUILDDIR/settings.conf` and module overrides into
`$BUILDDIR/src/modules/`. `run.sh` starts Xvfb on `:99` if needed and runs:

```text
cd $BUILDDIR && calamares -d
```

`-d` loads modules and esterOS branding from the build/source tree; `example.sqfs` is
referenced as `./example.sqfs` from `$BUILDDIR`.

## Configuration (source templates in `config/`)

- `config/settings.conf` — esterOS module sequence; omits Arch-only `initcpio` jobs
- `config/modules/unpackfs.conf` — unpacks `example.sqfs` to target `/`
- `config/modules/bootloader.conf` — BIOS `grub-install` to the target disk

Re-run `./ci/e2e/setup.sh` after editing templates to redeploy into `$BUILDDIR`.

Override paths:

```bash
export BUILDDIR=/workspace/build
export CALAMARES_E2E_DISK=/dev/vdb
```

## E2E walkthrough (manual)

1. Run `./ci/e2e/run.sh`.
2. Click through welcome, locale, keyboard.
3. On **Partition**, pick `$CALAMARES_E2E_DISK` → **Erase disk** (or manual layout on that disk only).
4. Create a user on **Users**.
5. Confirm **Summary**, then start the install.
6. Wait for the exec phase (partition → mount → unpackfs → … → bootloader → umount).
7. On **Finished**, run `sudo ./ci/e2e/verify.sh`.

Some exec jobs may log warnings on a minimal example root (e.g. `initramfs` inside an empty chroot). If the install fails, open **Debug** (available with `-d`) or check `/var/log/Calamares.log`.

## Local machine with a loop file

If you do not have a spare disk, create an image and use a loop device:

```bash
truncate -s 8G /var/tmp/calamares-e2e.img
sudo losetup -fP /var/tmp/calamares-e2e.img
export CALAMARES_E2E_DISK=$(losetup -j /var/tmp/calamares-e2e.img | cut -d: -f1)
./ci/e2e/run.sh
```

You may need a debug build with `DEBUG_PARTITION_UNSAFE=ON` if the loop device is hidden from the partition UI.
