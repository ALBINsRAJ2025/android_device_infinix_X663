# 📱 Infinix Note 11 (X663)

**Device tree for the Infinix Note 11 — MediaTek MT6768 / Helio G88 (MT6769H), Android 12.**

<p align="center">
  <img src="infinix-note-11-x663-github.png" alt="Infinix Note 11 X663" width="800" style="border-radius: 14px; box-shadow: 0 18px 40px rgba(0,0,0,0.45);" />
</p>

---

## Device

| | |
| --- | --- |
| **Model** | Infinix Note 11 (X663) |
| **SoC** | MediaTek MT6768 / Helio G88 (MT6769H) (2× Cortex-A75 + 6× Cortex-A55) |
| **Display** | 6.7" 1080×2400, 393 dpi, 60 Hz |
| **Stock ROM** | XOS 10.6.0, Android 12, `X663-H6915ABCEFGHIO-S-GL-230918V670` |
| **Partitions** | Virtual A/B, dynamic (`system`, `system_ext`, `product`, `vendor`) |
| **First API level** | 30 |
| **Vendor VNDK** | 31 |

## ✨ Highlights

- **Stock vendor policy** retained (v31) with platform policy v32 fallback handling.
- **Framework resource overlay** with corrected Android 12 power profile (6+2 cluster CPU layout).

## 🔨 Build

```bash
repo init -u https://android.googlesource.com/platform/manifest -b android-12.0.0_rXX
repo sync -j8

cp -a device/infinix/X663   aosp/device/infinix/
cp -a vendor/infinix/X663   aosp/vendor/infinix/
cp -a kernel/infinix/X663   aosp/kernel/infinix/
cd aosp
. build/envsetup.sh
lunch aosp_X663-userdebug
m -j$(nproc)
```

Useful image targets:

```bash
m bootimage dtboimage systemimage system_extimage productimage vendorimage \
  vbmetaimage vbmeta_systemimage vbmeta_vendorimage superimage
```

`vendorimage` builds an ext4 vendor filesystem; it does not copy a prebuilt image.

## ⚖️ Licensing

Original device-tree files are licensed under **Apache-2.0** (see `LICENSE` and `NOTICE`).
The stock APN database, the prebuilt `mtk_plpath_utils` binary and stock-derived
recovery/fstab files are third-party material and are not relicensed. Files marked
`LicenseRef-Stock-Firmware` remain subject to Infinix/Transsion terms.

## ⚠️ Notes and limitations

- The trees have **not** been compiled or booted against a full AOSP checkout in this
  environment; wiring is validated by inspection and stock vendor metadata comparison.
- The prebuilt kernel is stock; kernel source was not published with the firmware.
- The stock vendor policy is version 31 while LineageOS 19.1 platform policy is version 32;
  runtime fallback and vendor HAL loading still need a device test.
- AVB uses AOSP test keys and disabled verification for unlocked devices; replace the test
  keys before distributing production builds.
