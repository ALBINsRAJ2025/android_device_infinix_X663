# Vendor SELinux policy (port)

The stock vendor policy is MediaTek's Android 12 policy (version 31) plus the
vendor rules. Only the vendor rules are in the device's vendor tree. AOSP 12
compiles the vendor policy from `.te` sources in
`BOARD_VENDOR_SEPOLICY_DIRS`; a prebuilt `vendor_sepolicy.cil` cannot be fed
into the policy build.

## Contents

```
sepolicy/
├── README.md              this file
├── convert_cil_to_te.py   converts the stock vendor_sepolicy.cil to .te
├── aosp_provided_types.txt  AOSP 12.1 types (declarations to skip)
├── aosp_provided_attrs.txt  AOSP 12.1 attributes (declarations to skip)
├── vendor.te              the converted vendor policy
└── mtk_platform.te        MTK platform symbols to add (currently empty)
```

## Conversion

```bash
python3 sepolicy/convert_cil_to_te.py \
    /sdcard/x663project/stock_firmware/unpacked/sepolicy/vendor_sepolicy.cil \
    sepolicy/vendor.te \
    --types sepolicy/aosp_provided_types.txt \
    --attrs sepolicy/aosp_provided_attrs.txt
```

Keeps every `allow`/`dontaudit`/`allowxperm`/`type_transition`/`genfscon`
rule; skips AOSP 12.1-declared types (124) and attributes (8); drops
`neverallow` (AOSP runs that check), `roletype` (single role `r`) and
`typealias` (expanded). Verified by rule equivalence: 8,948 rules and 919
genfscon/type_transition statements, 0 missing / 0 extra.

## Enabling

`BoardConfig.mk` gates the port:

```make
X663_SEPOLICY_PORT ?= false

X663_SEPOLICY_DIRS :=
ifeq ($(X663_SEPOLICY_PORT),true)
X663_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy
endif
BOARD_VENDOR_SEPOLICY_DIRS := $(X663_SEPOLICY_DIRS)
```

`BOARD_SEPOLICY_VERS := 31.0` is set unconditionally in `BoardConfig.mk`: the
stock vendor policy and the stock vendor manifest are both version 31.0, and
the mixed build (platform 32.0, vendor 31.0) compiles the ported policy against
`prebuilts/api/31.0`.

## Mixed-build compat

The mixed build also compiles Lineage's current `system_ext` policy (32.0)
against the 31.0 platform prebuilts. Two attributes from
`system/sepolicy/public/attributes` are new in 32.0 and missing from the 31.0
prebuilts:

| Attribute | Used by |
| --- | --- |
| `sdcard_posix_contextmount_type` | `device/lineage/sepolicy/common/private/file.te` |
| `hal_service_type` | `device/lineage/sepolicy/common/dynamic/service.te` |

`sepolicy_compat/public/attributes` declares both and `BoardConfig.mk`
prepends that directory:

```make
BOARD_SYSTEM_EXT_PUBLIC_PREBUILT_DIRS = $(DEVICE_PATH)/sepolicy_compat/public $(SYSTEM_EXT_PUBLIC_POLICY)
```

The variable is recursive on purpose: it is read after
`SYSTEM_EXT_PUBLIC_POLICY` is filled in, so the Lineage `system_ext` public
policy stays in the list. Only mixed builds read it; normal builds never see
the directory. The pair above is the complete set: every identifier used by
`device/lineage/sepolicy/common` and by the 32.0 `system/sepolicy/vendor`
sources resolves against the 31.0 prebuilts once both are declared.

## Build-time neverallow assertions

The 31.0 prebuilts still carry the Android 12.0 neverallows, while the
`system_ext` policy compiled in this mixed build is Lineage's 12L policy.
Android 12L's current `public/domain.te` exempts the `recovery` and
`sdcard_posix_contextmount_type` rules below; the 31.0 prebuilts do not, and
reject them:

| Rejected rule | Rejecting prebuilt |
| --- | --- |
| `allow vold sdcard_posix:filesystem relabelto` | `prebuilts/api/31.0/public/domain.te:512` |
| `allow recovery rootfs:file { create_file_perms link }` | `prebuilts/api/31.0/public/domain.te:508` |
| `allow recovery self:capability mknod` | `prebuilts/api/31.0/public/domain.te:383` |

`BoardConfig.mk` turns the build-time assertions off for every variant except
`user`:

```make
ifneq ($(TARGET_BUILD_VARIANT),user)
SELINUX_IGNORE_NEVERALLOWS := true
endif
```

The switch affects the compile-time check only. No domain becomes permissive,
every `allow` rule is kept, and the policy installed on the device is still
enforcing. `user` builds keep the assertions and still stop at the same three
rules until the vendor policy port replaces the mixed `system_ext` input.

Off (default): platform policy + AOSP generic vendor policy; the missing
vendor rules appear as `avc: denied`. On: compile `vendor.te`; the first build
reports the symbols only MTK's platform policy provided, and they go into
`mtk_platform.te` (with the log line), one by one.
