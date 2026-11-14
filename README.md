# device/infinix/X663

Device tree for the **Infinix Note 11 (X663)**, MediaTek MT6768 / Helio G88,
targeting **AOSP 12** (`android-12.0.0_r*`, SP1A.210812.016) and usable with
**LineageOS 19.1**.

## Device

| | |
| --- | --- |
| Model | Infinix Note 11 (X663) |
| SoC | MediaTek MT6768 / Helio G88 (2× Cortex-A75 + 6× Cortex-A55) |
| Display | 6.7" 1080×2460, 480 dpi, 60 Hz |
| Stock ROM | XOS 10.6.0, Android 12, `X663-H6915ABCEFGHIO-S-GL-230918V670` |
| Partitions | virtual A/B, dynamic (`system`, `system_ext`, `product`, `vendor`) |
| First API level | 30 |
| Vendor VNDK | 31 (AOSP 12 ships it; 12L installs the v31 snapshot) |

## Vendor mode

This tree uses a **normal source-built vendor partition**.  There is no
`vendor.img` in the device tree, vendor tree or delivery, and
`BOARD_PREBUILT_VENDORIMAGE` is not set.

`device.mk` inherits `vendor/infinix/X663/X663-vendor.mk`, which installs the
stock blobs from `vendor/infinix/X663/proprietary/`.  The vendor repository's
`Android.mk` recreates the 196 stock symlinks that `PRODUCT_COPY_FILES` cannot
preserve.  `configs/fs_config` supplies the stock ownership and mode metadata
through `TARGET_FS_CONFIG_GEN`.

The stock vendor SELinux policy is kept as shipped:

* `vendor_sepolicy.cil`, context files and `precompiled_sepolicy` come from
  the blob tree;
* `selinux_policy_nonsystem` is filtered out;
* `PRODUCT_PRECOMPILED_SEPOLICY := false` prevents AOSP from replacing the
  stock policy;
* no reconstructed MTK `.te` sources are added.

## Tree layout

```
device/infinix/X663/
├── AndroidProducts.mk
├── aosp_X663.mk              # AOSP 12 product
├── lineage_X663.mk           # LineageOS 19.1 product
├── BoardConfig.mk            # kernel, partitions, AVB, vendor build, density
├── device.mk                 # dynamic partitions, fstab, recovery, APNs
├── vendor.prop               # stock vendor properties
├── configs/apns-conf.xml     # stock carrier APN database
├── configs/fs_config         # stock vendor ownership/modes
├── overlay/frameworks/base/core/res/
│   ├── res/values/config.xml       # framework config overlay
│   ├── res/values/dimens.xml       # status bar / cutout dimensions
│   └── res/xml/power_profile.xml   # corrected MT6768 power profile
├── recovery/
│   ├── Android.mk
│   └── root/
│       ├── init.recovery.mt6768.rc
│       ├── system/bin/mtk_plpath_utils
│       └── system/etc/init/mtk-plpath-utils.rc
├── rootdir/etc/fstab.mt6768
├── extract-files.sh
├── LICENSE
├── NOTICE
└── README.md
```

The kernel is in `kernel/infinix/X663`; the vendor tree is in
`vendor/infinix/X663`.

## Building

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

`vendorimage` builds an ext4 vendor filesystem; it does not copy a prebuilt
image.

## Licensing

Original device-tree files are licensed under **Apache-2.0**; see `LICENSE`
and `NOTICE`.  The stock APN database, the prebuilt `mtk_plpath_utils` binary
and stock-derived recovery/fstab files are third-party material and are not
relicensed.  Files marked `LicenseRef-Stock-Firmware` remain subject to
Infinix/Transsion terms.

## Notes and limitations

* The trees have **not** been compiled or booted against a full AOSP checkout
  in this environment.  The wiring is validated by inspection and by
  comparing the stock vendor metadata, not by a build.
* The prebuilt kernel is stock; kernel source was not published with the
  firmware.  `Image.gz`, the DTB and `dtbo.img` are in the kernel tree.
* The stock vendor policy is version 31 while LineageOS 19.1 platform policy
  is version 32.  Runtime fallback, linkerconfig mapping and vendor HAL loading
  still need a device test.
* AVB uses AOSP test keys and disabled verification for unlocked devices.
  Replace the test keys before distributing production builds.
