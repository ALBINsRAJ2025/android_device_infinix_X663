# Recovery ramdisk — stock provenance and naming

This folder reproduces the **stock X663 recovery ramdisk** that the device
runs in recovery-as-boot mode.  The reference is the stock SP Flash Tool
package `stock_firmware/spflashtool_firmware/boot.img`, decoded with the
Android 12 otatools:

```bash
unpack_bootimg --boot_img stock_firmware/spflashtool_firmware/boot.img --out boot/
# boot/ramdisk is a gzip cpio archive
gzip -dc boot/ramdisk | cpio -idm
```

The decoded ramdisk contains **213 regular files and 205 symlinks**.  Its
layout and every file name are the stock ones; this tree ships the subset
that the build actually installs, under the stock names.

## What is shipped here and why

| Tree path | Stock path in the ramdisk | Why it is here |
| --- | --- | --- |
| `root/init.recovery.mt6768.rc` | `/init.recovery.mt6768.rc` | the stock recovery init script; installed by `recovery/Android.mk` into `$(TARGET_RECOVERY_OUT)/root` |
| `root/system/bin/mtk_plpath_utils` | `/system/bin/mtk_plpath_utils` | MTK path-utils helper that creates the `bootloader1/2`, `preloader_raw_a/b` and `mmcblk0boot0/1` device aliases; installed as a prebuilt into `$(TARGET_RECOVERY_OUT)/root/system/bin` |
| `root/system/etc/init/mtk-plpath-utils.rc` | `/system/etc/init/mtk-plpath-utils.rc` | the init fragment that starts the helper (`on boot start mtk.plpath.utils.link`) |

The stock ramdisk also carries the first-stage tools
(`first_stage_ramdisk/system/bin/e2fsck`, `first_stage_ramdisk/system/bin/snapuserd`)
and the fstab (`first_stage_ramdisk/fstab.mt6768`).  Those are **not** shipped
here: the build produces its own first-stage ramdisk from the device tree and
copies `e2fsck`/`snapuserd` through `BOARD_RECOVERY_IMAGE_PREPARE`.  The stock
fstab is the source of `device/infinix/X663/rootdir/etc/fstab.mt6768`.

## Deviations from the stock files (and why)

| File | Deviation | Reason |
| --- | --- | --- |
| `init.recovery.mt6768.rc` | three extra header lines (`SPDX-License-Identifier`, `Copyright`, `Derived from stock`) | the file is stock-derived third-party material; the headers record its origin and licensing |
| `system/bin/mtk_plpath_utils` | replaced with the **ramdisk build** of the binary (54,920 bytes, SHA-256 `1f9b303cb8a00fcc72e6f38543621c3fe013902a2c9ee21fb145f1695a747f29`) | the stock *system partition* carries a different build of the same tool (54,992 bytes, SHA-256 `01c19239b77931ba963fc795280668ebe1b8a43201764cc8ab94af612eae0358`); the ramdisk variant is the one the stock boot image actually executes, so it is the faithful choice for a recovery ramdisk |
| `first_stage_ramdisk/fstab.mt6768` → `device/infinix/X663/rootdir/etc/fstab.mt6768` | AVB-enforcing options replaced by AVB-relaxed ones | the stock fstab uses `avb=vbmeta_system` and the Infinix `avb_keys`; the source build signs with the AOSP test key and `--flags 3`, so the strict options would not boot |

Everything else in this folder is byte-identical to the stock ramdisk.

## Licensing

`mtk_plpath_utils` is a stock MediaTek binary and is **not** relicensed by
this tree; see the repository `NOTICE`.  `init.recovery.mt6768.rc` is marked
`Apache-2.0 AND LicenseRef-Stock-Firmware`.
