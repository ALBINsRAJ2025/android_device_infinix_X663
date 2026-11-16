# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2026 ALBINsRAJ2025
#
# BoardConfig.mk - Infinix Note 11 (X663)
#
# MediaTek MT6768 / Helio G88
# Stock firmware: X663-H6915ABCEFGHIO-S-GL-230918V670
#

DEVICE_PATH := device/infinix/X663

TARGET_FS_CONFIG_GEN := $(DEVICE_PATH)/configs/fs_config
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

-include vendor/infinix/X663/BoardConfigVendor.mk

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a-dotprod
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a75

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

TARGET_SUPPORTS_64_BIT_APPS := true
TARGET_USES_64_BIT_BINDER := true

# Display
TARGET_SCREEN_DENSITY := 480

# Platform
# Keep the stock ro.product.board; the vendor blobs read it.
TARGET_BOARD_PLATFORM := mt6768
TARGET_BOOTLOADER_BOARD_NAME := Infinix-X663
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

# Kernel (stock boot.img is header v2, 2048-byte pages)
BOARD_BOOT_HEADER_VERSION := 2
BOARD_KERNEL_IMAGE_NAME := Image.gz

BOARD_KERNEL_BASE := 0x40078000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x07c08000
BOARD_KERNEL_TAGS_OFFSET := 0x0bc08000
BOARD_KERNEL_SECOND_OFFSET := 0x00000000
BOARD_DTB_OFFSET := 0x0bc08000

# buildvariant is appended by the build system.
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2

# The kernel is shipped as a payload only (Image.gz, dtb/, dtbo.img); there is
# no kernel source tree.  Lineage's kernel.mk tests the mere existence of
# $(TARGET_KERNEL_SOURCE) to decide between a source build and the prebuilt
# path (vendor/lineage/build/tasks/kernel.mk:120-163), and
# vendor/lineage/config/BoardConfigKernel.mk:52-53 defaults that variable to
# kernel/$(vendor)/$(device) - which is exactly where this payload is synced.
# With a directory present and no TARGET_KERNEL_CONFIG, kernel.mk aborts with
# $(error "NO KERNEL CONFIG").  Keeping TARGET_KERNEL_SOURCE empty selects the
# prebuilt path; AOSP 12 has no kernel.mk and takes device.mk's
# PRODUCT_COPY_FILES Image.gz:kernel rule instead.
TARGET_KERNEL_SOURCE :=
TARGET_PREBUILT_KERNEL := kernel/infinix/X663/Image.gz
BOARD_PREBUILT_DTBIMAGE_DIR := kernel/infinix/X663/dtb
BOARD_INCLUDE_DTB_IN_BOOTIMG := true

BOARD_KERNEL_SEPARATED_DTBO := true
# Unsigned stock DTBO; the build adds the AVB footer.
BOARD_PREBUILT_DTBOIMAGE := kernel/infinix/X663/dtbo.img
BOARD_DTBOIMG_PARTITION_SIZE := 8388608

BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --base $(BOARD_KERNEL_BASE)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --second_offset $(BOARD_KERNEL_SECOND_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)
BOARD_MKBOOTIMG_ARGS += --board "CY-X663-H6915"

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432

BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_FLASH_BLOCK_SIZE := 131072

TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext

# Virtual A/B and dynamic partitions
BOARD_SUPER_PARTITION_SIZE := 7755374592
BOARD_SUPER_PARTITION_GROUPS := main
BOARD_MAIN_SIZE := 7753277440
BOARD_MAIN_PARTITION_LIST := \
    system \
    system_ext \
    product \
    vendor

BOARD_USES_METADATA_PARTITION := true

TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.mt6768
TARGET_OTA_ASSERT_DEVICE := Infinix-X663,X663

# Recovery UI
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_UI_MARGIN_HEIGHT := 124

# Virtual A/B OTA
AB_OTA_UPDATER := true
BOARD_USES_RECOVERY_AS_BOOT := true

AB_OTA_PARTITIONS := \
    boot \
    dtbo \
    vbmeta \
    product \
    system \
    system_ext \
    vbmeta_system \
    vbmeta_vendor \
    vendor

# Verified boot (test keys; replace before production)
BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA2048
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3

BOARD_AVB_VBMETA_SYSTEM := system product
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_VBMETA_VENDOR := vendor
BOARD_AVB_VBMETA_VENDOR_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_VENDOR_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX := 0
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX_LOCATION := 4

BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA2048
BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_BOOT_ROLLBACK_INDEX := 0
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 3

# VNDK (stock blobs are VNDK 31)
ifeq ($(PLATFORM_SDK_VERSION),32)
BOARD_VNDK_VERSION := 31
else
BOARD_VNDK_VERSION := current
endif

# Vendor SELinux policy port
# Kernel cannot be made permissive (DEVELOP=n, BOOTPARAM=n); see the
# sepolicy/ and sepolicy_permissive/ READMEs for the details and the plan.
X663_SEPOLICY_PORT ?= false
X663_SELINUX_PERMISSIVE ?= false

X663_SEPOLICY_DIRS :=
ifeq ($(X663_SEPOLICY_PORT),true)
X663_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy
# the stock vendor policy was written against platform policy version 31
BOARD_SEPOLICY_VERS := 31
endif
ifeq ($(X663_SELINUX_PERMISSIVE),true)
# userdebug/eng only; marks every policy type permissive.
X663_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy_permissive
endif
BOARD_VENDOR_SEPOLICY_DIRS := $(X663_SEPOLICY_DIRS)

# Vendor image: built from vendor/infinix/X663, stock policy kept.
VENDOR_SECURITY_PATCH := 2023-09-05
