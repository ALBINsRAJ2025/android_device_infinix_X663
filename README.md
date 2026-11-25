# 📱 Infinix Note 11 X663

**Device tree for the Infinix Note 11 — MediaTek MT6768 / Helio G88 (MT6769H), Android 12.**

<p align="center">
  <img src="infinix-note-11-x663-github.png" alt="Infinix Note 11 X663" width="800" style="border-radius: 14px; box-shadow: 0 18px 40px rgba(0,0,0,0.45);" />
</p>

---

## Device Specifications

| | |
| --- | --- |
| **Model** | Infinix Note 11 (X663) |
| **SoC** | MediaTek MT6768 / Helio G88 (MT6769H) (2× Cortex-A75 + 6× Cortex-A55) |
| **Display** | 6.7" 1080×2400, 393 dpi, 60 Hz |
| **Stock ROM** | XOS 10.6.0, Android 12, `X663-H6915ABCEFGHIO-S-GL-230918V670` |
| **Partitions** | Virtual A/B, dynamic (`system`, `system_ext`, `product`, `vendor`) |
| **First API level** | 30 |
| **Vendor VNDK** | 31 |

## 🚦 Current State / Status

- **Compilation**: **Build completed successfully** (`lineage-19.1` compiles cleanly to flashable zip via `mka bacon`).
- **Boot Status**: **Stuck at splash screen** (device reaches the initial Infinix boot splash logo, currently under active bring-up / early init debugging).

## 🔨 Build

Build with the official LineageOS guide, cloning the two repositories into the source tree.
The prebuilt kernel payload (`Image.gz`, `dtb/`, `dtbo.img`, `defconfig`) ships inside this
tree under `kernel/`, so no separate kernel repository is needed:

```bash
mkdir -p ~/android/lineage
cd ~/android/lineage

repo init -u https://github.com/LineageOS/android.git -b lineage-19.1 --git-lfs
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

git clone https://github.com/ALBINsRAJ2025/android_device_infinix_X663 \
    -b lineage-19.1 device/infinix/X663
git clone https://github.com/ALBINsRAJ2025/android_vendor_infinix_X663 \
    -b lineage-19.1 vendor/infinix/X663

source build/envsetup.sh
lunch lineage_X663-userdebug
mka bacon -j$(nproc --all)
```

## ⚖️ Licensing

Original device-tree files are licensed under **Apache-2.0** (see `LICENSE` and `NOTICE`).

## ⚠️ Notes and limitations

- Full ROM build succeeds, but initial boot is currently stuck at splash screen; early init and vendor HAL initialization are being actively investigated.
- The prebuilt kernel is stock; kernel source was not published with the firmware.
- The stock vendor policy is version 31 while LineageOS 19.1 platform policy is version 32; runtime fallback and vendor HAL loading are being tuned.
- AVB uses AOSP test keys and disabled verification for unlocked devices; replace the test keys before distributing production builds.
