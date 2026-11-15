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
ifeq ($(X663_SEPOLICY_PORT),true)
BOARD_VENDOR_SEPOLICY_DIRS := $(LOCAL_PATH)/sepolicy
BOARD_SEPOLICY_VERS := 31
endif
```

Off (default): platform policy + AOSP generic vendor policy; the missing
vendor rules appear as `avc: denied`. On: compile `vendor.te`; the first build
reports the symbols only MTK's platform policy provided, and they go into
`mtk_platform.te` (with the log line), one by one.
