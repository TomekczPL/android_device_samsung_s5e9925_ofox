# OrangeFox Recovery — Samsung Galaxy S22 series (Exynos 2200)

Unofficial **OrangeFox R12.0** recovery for the Samsung Galaxy S22 family with Exynos 2200 (SoC codename `s5e9925`).


| Model | Codename | Lunch target | Tested |
|---|---|---|---|
| Galaxy S22 | `r0s` (SM-S901B) | `twrp_r0s-eng`
| Galaxy S22+ | `g0s` (SM-S906B) | `twrp_g0s-eng`
| Galaxy S22 Ultra | `b0s` (SM-S908B) | `twrp_b0s-eng`

## ✅ What works

- Boot, touch, display
- ADB sideload, MTP, file browser
- Flash custom ROMs / Magisk / KernelSU zips
- Wipe / Format Data
- Backup / Restore (to `/cache` thanks to `FOX_MISCELLANEOUS_ROOT_DIRECTORY`)
- Mount of system / vendor / vendor_dlkm / product / odm (dynamic partitions)
- **Persistent settings across reboots** — themes, brightness, language, custom configs all stick

## ⚠️ Known issues

| Issue | Status |
|---|---|
| `/data` decryption | **Not fixable in custom recovery.** Samsung's FBE + metadata encryption uses keys from Knox Vault / TEE that custom recovery can't access. Userdata appears as raw blocks. Workaround: format data, or use ADB from booted Android for file transfer. |
| Flashlight | Disabled. S22 routes torch via `/sys/devices/virtual/camera/flash/rear_flash`, which doesn't fit OFRP's `OF_FL_PATH` convention (OFRP appends `/brightness` to the path). |
| Haptic feedback | Not implemented in the device tree . |

## 🎨 Baked-in defaults

OFRP boots with these out-of-the-box (and they stick across reboots via `/cache`):

- Theme: **Cream** (warm brand-style)
- Brightness: **30 %** (153 / 510)
- Status-bar clock: **centered**
- Hidden files: **visible**
- Gesture navigation: **off**
- Force fast charging: **on**

You can change any of them in OFRP Settings → Customization. Changes persist.


## 🛠️ Build from source

Tested on Ubuntu 22.04 in WSL2 with 12 cores / 12 GB RAM. Needs ~150 GB free disk.

```bash
# 1) Build deps
sudo apt install -y bc bison build-essential ccache curl flex g++-multilib \
  gcc-multilib git git-lfs gnupg gperf imagemagick lib32readline-dev lib32z1-dev \
  libelf-dev liblz4-tool libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop \
  pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev fontconfig \
  openjdk-11-jdk python-is-python3 python3 python3-pip aria2 unzip xz-utils

# 2) repo tool
sudo curl -L https://storage.googleapis.com/git-repo-downloads/repo \
  -o /usr/local/bin/repo && sudo chmod a+x /usr/local/bin/repo

# 3) OFRP source sync (~80 GB)
mkdir ~/src && cd ~/src
git clone https://gitlab.com/OrangeFox/sync.git
cd sync
./orangefox_sync.sh --branch 12.1 --path ~/fox_12.1

# 4) This device tree
git clone https://github.com/TomekczPL/android_device_samsung_s5e9925_ofox \
  ~/fox_12.1/device/twrp/s5e9925 -b android-12.1

# 5) Apply the OFRP defaults patch
cd ~/fox_12.1/bootable/recovery
git apply ~/fox_12.1/device/twrp/s5e9925/patches/0001-ofrp-baked-defaults.patch

# 6) Build (pick your codename)
cd ~/fox_12.1
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true LC_ALL=C
export FOX_BUILD_DEVICE=g0s         # or r0s / b0s
lunch twrp_g0s-eng
mka recoveryimage
```

Result: `out/target/product/<codename>/OrangeFox-R12.0-Unofficial-<codename>.img`


## 🧱 What changed vs. upstream `milxnaq/android_device_samsung_s5e9925`

| Commit | Why |
|---|---|
| `device: copy per-codename recovery/root into ramdisk` | Upstream only copied common ramdisk content; per-codename kernel modules under `<cn>/recovery/root/lib/modules` were never bundled. Touch/UFS/panel drivers loaded as a result. |
| `device: configure OrangeFox flashlight LED paths` | Samsung uses `torch-sec1` / `leds-sec1` naming, not the LED paths OFRP probes by default. Also drops brightness from 50 % → 30 %. |
| `fstab: add /cache mount` | `/cache` is ext4 read-write and almost unused on modern Samsungs. We need a writable, unencrypted partition for OFRP storage. |
| `vendorsetup: FOX_SETTINGS_ROOT_DIRECTORY=/cache/OFRP` | Without this, OFRP tries to write settings/backups to `/data/media/`, which is encrypted on S22 — every boot would lose configuration. Redirecting to `/cache` makes the build usable. |
| `patches/0001-ofrp-baked-defaults.patch` | Applies sensible defaults (Cream theme, fast charge on, etc.) to OFRP's `data.cpp`. |

## 🙏 Credits

- **[milxnaq](https://github.com/milxnaq)** — upstream TWRP device tree, kernel prebuilts, sepolicy, all the heavy lifting.
- **[OrangeFox team](https://gitlab.com/OrangeFox)** — recovery, vendor tree, build system.
- **[TWRP team](https://twrp.me)** — base recovery & minimal manifest.

## License

Apache License 2.0
