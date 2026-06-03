# AGENTS.md

## Cursor Cloud specific instructions

Calamares is a **Qt/C++ CMake** Linux installer framework (single native app + plugin modules), not a web stack. There is no `package.json`, Docker Compose, or root-level Node tooling.

### Services / processes

| Component | Role |
|-----------|------|
| **Built `calamares` binary** (`/workspace/build/calamares` after configure) | Main installer GUI |
| **`loadmodule`** (`/workspace/build/loadmodule`) | Headless/single-module tester (some view modules need a display) |
| **Xvfb + `DISPLAY`** | Headless Qt UI for `calamares -d` or GUI `loadmodule` |
| **`example.sqfs`** (`ninja example-distro` in build dir) | Sample root FS for default unpackfs dev path |
| **D-Bus / polkitd** | Optional but closer to real installs for some modules |

CI (`.github/workflows/push.yml`) builds inside **Fedora 40** with Qt6 (`./ci/deps-fedora-qt6.sh`). This cloud VM is **Ubuntu 24.04**; use Qt5 deps instead (`./ci/deps-ubuntu.sh`).

### Standard commands (Ubuntu cloud VM)

**One-time / update-script system deps** (also needs `ninja-build`, `squashfs-tools`, and `g++` / `libstdc++-12-dev` if the default `c++` is Clang without libstdc++):

```bash
sudo bash ci/deps-ubuntu.sh
sudo apt-get install -y ninja-build squashfs-tools g++ libstdc++-12-dev
```

**Configure & build** (matches local dev; install to `/usr` will fail without root — use the build-tree binary):

```bash
export SRCDIR=/workspace BUILDDIR=/workspace/build
export CC=gcc CXX=g++
export CMAKE_ARGS="-DKDE_INSTALL_USE_QT_SYS_PATHS=ON -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON -DBUILD_SCHEMA_TESTING=ON"
rm -rf "$BUILDDIR"
./ci/build.sh
# Binary: $BUILDDIR/calamares — skip `ninja install` unless CMAKE_INSTALL_PREFIX is writable
```

**Incremental rebuild** after pull:

```bash
ninja -C /workspace/build
```

**Tests**

- Full suite: `ctest --output-on-failure -j$(nproc)` from `/workspace/build` (needs ECM + Python jsonschema/PyYAML; a few locale/keyboard tests may fail on minimal images).
- Config/schema tooling: `python3 ci/configvalidator.py -x` and per-module validation via CTest `validate-*` targets.
- Python module lint: CTest targets named `lint-<module>` when `pylint3` is installed.

**Dev-mode installer smoke test** (core “hello world” — loads branding, QML, modules; does not require root):

```bash
export DISPLAY=:99
Xvfb :99 -screen 0 1280x720x24 &
cd /workspace/build
./calamares -d
```

Optional: `ninja -C /workspace/build example-distro` then run with default `settings.conf` (unpackfs uses `example.sqfs`). A full install still needs root, real block devices, and elevated partition/mount jobs.

### Gotchas

- `ci/deps-ubuntu.sh` lists the package `ninja`, but on Ubuntu the binary comes from **`ninja-build`**.
- Prefer **`CC=gcc CXX=g++`** for CMake’s compiler probe; bare `c++` may be Clang without `-lstdc++`.
- `./ci/build.sh` always runs **`ninja install`**; without `sudo` or a custom `CMAKE_INSTALL_PREFIX`, install fails even when the compile succeeds. Use `$BUILDDIR/calamares` directly for dev.
- GitHub Actions uses **Qt6 on Fedora**; Ubuntu 24.04 here uses **Qt5** via `deps-ubuntu.sh` (no `WITH_QT6=ON` unless you add Qt6/KF6 packages yourself).

See `CMakeLists.txt` (Example Distro / `calamares -d` comments) and `settings.conf` for the default module sequence.
