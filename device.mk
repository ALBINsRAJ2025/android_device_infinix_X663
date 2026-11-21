# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2026 ALBINsRAJ2025
# device.mk - Infinix Note 11 (X663)

LOCAL_PATH := device/infinix/X663

# Stock vendor payload
$(call inherit-product, vendor/infinix/X663/X663-vendor.mk)

PRODUCT_COPY_FILES := $(filter-out \
    vendor/infinix/X663/proprietary/etc/fs_config_files:$(TARGET_COPY_OUT_VENDOR)/etc/fs_config_files \
    vendor/infinix/X663/proprietary/etc/fs_config_dirs:$(TARGET_COPY_OUT_VENDOR)/etc/fs_config_dirs \
    vendor/infinix/X663/proprietary/etc/passwd:$(TARGET_COPY_OUT_VENDOR)/etc/passwd \
    vendor/infinix/X663/proprietary/etc/group:$(TARGET_COPY_OUT_VENDOR)/etc/group \
    vendor/infinix/X663/proprietary/odm/etc/passwd:$(TARGET_COPY_OUT_VENDOR)/odm/etc/passwd \
    vendor/infinix/X663/proprietary/odm/etc/group:$(TARGET_COPY_OUT_VENDOR)/odm/etc/group \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml \
    vendor/infinix/X663/proprietary/overlay/FrameworkResOverlay/FrameworkResOverlay.apk:$(TARGET_COPY_OUT_VENDOR)/overlay/FrameworkResOverlay/FrameworkResOverlay.apk \
    ,$(PRODUCT_COPY_FILES))


PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6768

# Framework resource overlay
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# Virtual A/B
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression_retrofit.mk)

# A/B OTA
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

PRODUCT_PACKAGES += \
    otapreopt_script \
    update_engine \
    update_engine_sideload \
    update_verifier

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

# Userspace fastboot
PRODUCT_PACKAGES += \
    fastbootd

# Recovery boot/health passthrough HALs
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl.recovery

PRODUCT_SHIPPING_API_LEVEL := 30
PRODUCT_CHARACTERISTICS := phone

ifeq ($(PLATFORM_SDK_VERSION),32)
PRODUCT_EXTRA_VNDK_VERSIONS := 31
PRODUCT_VENDOR_PROPERTIES += ro.vndk.version=31
endif

PRODUCT_PRECOMPILED_SEPOLICY := false

# Recovery-as-boot fstab
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_RECOVERY)/root/first_stage_ramdisk/fstab.mt6768

# Stock carrier APN database
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/apns-conf.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/apns-conf.xml

# Recovery ramdisk
PRODUCT_PACKAGES += \
    init.recovery.mt6768.rc \
    mtk_plpath_utils \
    mtk-plpath-utils.rc \
    mtk-usb.rc \
    ueventd.mt6768.rc \
    android.hardware.boot@1.2.so \
    libhardware.so \
    libmtk_bsg.so \
    android.hardware.boot@1.0-impl-1.2-mtkimpl.so

ifeq ($(wildcard vendor/lineage/build/tasks/kernel.mk),)
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/kernel/Image.gz:kernel
endif

# First-boot debug logging
include $(LOCAL_PATH)/debug/debug-bootloop.mk
