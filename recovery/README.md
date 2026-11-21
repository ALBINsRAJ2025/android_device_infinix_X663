# Recovery ramdisk — stock provenance

This folder reproduces the stock X663 recovery ramdisk (recovery-as-boot),
decoded from the stock firmware with
`unpack_bootimg --boot_img <stock>/boot.img --out boot/` and
`gzip -dc boot/ramdisk | cpio -idm`. The stock ramdisk has 213 files and 205
symlinks; this tree ships what the build installs, under the stock names.

## Shipped files

| Tree path | Stock path |
| --- | --- |
| `root/init.recovery.mt6768.rc` | `/init.recovery.mt6768.rc` |
| `root/system/bin/mtk_plpath_utils` | `/system/bin/mtk_plpath_utils` |
| `root/system/etc/init/mtk-plpath-utils.rc` | `/system/etc/init/mtk-plpath-utils.rc` |
| `root/system/lib64/libhardware.so` | `/system/lib64/libhardware.so` |

`libhardware.so` (10,728 B, sha256 `c6dbe2e2…c35b74`) is the stock ramdisk copy
and the `DT_NEEDED` of the stock boot HAL implementation; without it
`update_engine_sideload` cannot `dlopen` the HAL and the sideload aborts with
`Error initializing the BootControlInterface`.

First-stage tools (`e2fsck`, `snapuserd`, `fstab.mt6768`) are **not** shipped:
the build generates its own first-stage ramdisk from this device tree
(`e2fsck_ramdisk` from `virtual_ab_ota/launch.mk` and `snapuserd` are installed
into `recovery/root/first_stage_ramdisk/system/bin`, and `device.mk` copies the
fstab to `recovery/root/first_stage_ramdisk/`).

## Deviations from stock

| File | Deviation | Why |
| --- | --- | --- |
| `init.recovery.mt6768.rc` | 3 added header lines | records stock origin and licensing |
| `system/bin/mtk_plpath_utils` | the ramdisk build (54,920 B), not the system-partition build | that is the binary the stock boot image actually runs |

`rootdir/etc/fstab.mt6768` (in the device tree) is the stock fstab with the
AVB options removed, because this build uses test keys and `--flags 3`.

`mtk_plpath_utils` is a MediaTek binary, not relicensed; `init.recovery.mt6768.rc`
is `Apache-2.0 AND LicenseRef-Stock-Firmware`.
