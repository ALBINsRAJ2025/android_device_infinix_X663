# Prebuilt kernel payload

Vendored inside the device tree at `device/infinix/X663/kernel/`.

Prebuilt kernel for the Infinix Note 11 (X663), MediaTek MT6768 / Helio G88,
from the stock firmware. No kernel source is published, so this tree ships
the stock binaries.

| File | Contents |
| --- | --- |
| `Image.gz` | Stock kernel, `4.19.191-g20c2dd72f5fd-dirty` (10,855,427 B) |
| `dtb/mt6768.dtb` | `dt_table` container from the stock boot image (119,464 B) whose only entry is the stock FDT (119,400 B) |
| `dtbo.img` | Unsigned DTBO table (49,472 B); the build pads and signs it to the 8 MiB partition |
| `defconfig` | Stock kernel config, GPL-2.0-only |

## File names vs the unpacked boot image

`unpack_bootimg` yields `kernel`, `dtb` and `ramdisk`; this tree uses the
Android build-system names. The `dtb` field is a `dt_table` container
(32 header + 32 entry bytes) whose single entry is the stock FDT, so the
file kept here is the complete 119,464-byte table, not the bare FDT:

| unpack_bootimg | This tree | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| `kernel` | `Image.gz` | 10,855,427 | `2a9dc96352c99a9462935f0024b53696a3f087320596a412125a41a997be72c5` |
| `dtb` (whole table) | `dtb/mt6768.dtb` | 119,464 | `6265c98f0439f053e1b27358d937b9e432f2f38fad93fcae8b2846861a750815` |
| `dtb` entry 0 (FDT) | — | 119,400 | `5dbaf472e07ee93c527404a4c5d8964f17a2f639d196ccf81eb7729f007d2d2c` |

Container layout: big-endian header (`magic 0xd7b7ab1e`, total size
119,464, header offset 32, header size 32, version 1, last-comp 32), one
entry at offset 32 (`dt_size` 119,400, `dt_offset` 64, id 0, rev 0), FDT at
offset 64.

`Image.gz` is required by `BOARD_KERNEL_IMAGE_NAME`. The build rule for
`BOARD_PREBUILT_DTBIMAGE_DIR` is only `cat *.dtb > dtb.img`
(`build/make/core/Makefile`), so nothing wraps or pads the file: the table
has to arrive complete, which is why `dtb/mt6768.dtb` is the container
itself. Keeping a bare FDT here produced a 119,400-byte `dtb` field with no
`dt_table` header, unlike stock.

## Building

```make
TARGET_PREBUILT_KERNEL       := $(DEVICE_PATH)/kernel/Image.gz
BOARD_PREBUILT_DTBIMAGE_DIR  := $(DEVICE_PATH)/kernel/dtb
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_KERNEL_SEPARATED_DTBO  := true
BOARD_PREBUILT_DTBOIMAGE     := $(DEVICE_PATH)/kernel/dtbo.img
```

Boot header values from the stock `boot.img` (v2, page 2048): base
`0x40078000`, kernel offset `0x8000`, ramdisk offset `0x07c08000`, tags/DTB
offset `0x0bc08000`.

## Licensing

`defconfig` is GPL-2.0-only. `Image.gz`, the DTB and `dtbo.img` are stock
firmware binaries, not relicensed; see `LICENSE` and `NOTICE`.
