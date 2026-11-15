# Vendor SELinux policy (port plan)

The stock vendor partition ships the complete SELinux material of the
device:

| Stock file | Role |
| --- | --- |
| `vendor/etc/selinux/vendor_sepolicy.cil` | the vendor policy in CIL (source form) |
| `vendor/etc/selinux/vendor_file_contexts` | the stock vendor file contexts (779 labels, many MTK-specific) |
| `vendor/etc/selinux/precompiled_sepolicy` | compiled platform+vendor policy (policydb version 30) |
| `vendor/etc/selinux/plat_pub_versioned.cil` | the device's platform public policy (version 31) |
| `vendor/etc/selinux/plat_sepolicy_vers.txt` | `31.0` — the policy version the vendor expects |

The measurements and the tool notes are in
`stock_firmware/unpacked/sepolicy/README.md`.

## Why this directory exists

`device.mk` currently sets

```make
PRODUCT_PRECOMPILED_SEPOLICY := false
```

so the build compiles the policy from source.  AOSP 12 compiles the **vendor**
policy from the `.te` sources in `BOARD_VENDOR_SEPOLICY_DIRS` — a prebuilt
`vendor_sepolicy.cil` cannot be fed into the policy build — and the device
tree currently sets no such directory.  The result would be

```
platform policy (AOSP / LineageOS 19.1, version 32)
  + AOSP's generic vendor policy
```

with none of MediaTek's vendor rules, while the stock file contexts in
`proprietary/etc/selinux/vendor_file_contexts` refer to types
(`mtk_agpsd_exec`, `mtk_cmdq_device`, …) that only exist in MTK's vendor
policy.

This directory is where the ported vendor policy will live.  It is empty on
purpose for now: the conversion and the symbol-by-symbol compile iteration
are tracked in `PENDING.md`, and shipping a half-converted policy would break
the build.

## Planned contents

```
sepolicy/
├── README.md        this file
├── vendor.te         converted from the stock vendor_sepolicy.cil
└── mtk_platform.te   the MTK platform symbols the vendor policy needs
```

## Planned wiring

```make
# device/infinix/X663/device.mk
BOARD_VENDOR_SEPOLICY_DIRS := $(LOCAL_PATH)/sepolicy
# the stock vendor policy was written against platform policy version 31
BOARD_SEPOLICY_VERS := 31
```

`BOARD_SEPOLICY_VERS := 31` selects the mixed build: AOSP 12.1 ships the
prebuilt v31 platform policy under
`system/sepolicy/prebuilts/api/31.0/`, so the vendor policy is compiled
against the platform policy version the device firmware was built with.

## Hard rules for the port

* Do not modify the stock blobs.  `vendor_sepolicy.cil`,
  `vendor_file_contexts` and `precompiled_sepolicy` stay exactly as the
  device ships them; the port produces *new* `.te` sources in this
  directory.
* The stock file contexts must win over the platform's generated ones,
  otherwise the MTK-specific labels disappear and the vendor HALs lose
  their domains.
* Every rule that is dropped or changed has to be recorded here with the
  reason.
* The result must pass `sepolicy-analyze`'s neverallow check and must not
  create `avc: denied` events for the vendor HALs at runtime.
