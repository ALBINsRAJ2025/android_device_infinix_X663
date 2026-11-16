# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2026 ALBINsRAJ2025
#
# device.mk - Infinix Note 11 (X663)
#

LOCAL_PATH := device/infinix/X663

# Stock vendor payload
$(call inherit-product, vendor/infinix/X663/X663-vendor.mk)

# Stock fs_config/passwd/group are empty; keep the platform-generated copies.
# The destinations must be written with $(TARGET_COPY_OUT_VENDOR): at product
# parse time it is still the ||VENDOR-PATH-PH|| placeholder, so a literal
# "vendor/" would match nothing and the stock copies would stay in the list.
PRODUCT_COPY_FILES := $(filter-out \
    vendor/infinix/X663/proprietary/etc/fs_config_files:$(TARGET_COPY_OUT_VENDOR)/etc/fs_config_files \
    vendor/infinix/X663/proprietary/etc/fs_config_dirs:$(TARGET_COPY_OUT_VENDOR)/etc/fs_config_dirs \
    vendor/infinix/X663/proprietary/etc/passwd:$(TARGET_COPY_OUT_VENDOR)/etc/passwd \
    vendor/infinix/X663/proprietary/etc/group:$(TARGET_COPY_OUT_VENDOR)/etc/group \
    vendor/infinix/X663/proprietary/odm/etc/passwd:$(TARGET_COPY_OUT_VENDOR)/odm/etc/passwd \
    vendor/infinix/X663/proprietary/odm/etc/group:$(TARGET_COPY_OUT_VENDOR)/odm/etc/group \
    vendor/infinix/X663/proprietary/etc/fstab.mt6768:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6768 \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml \
    vendor/infinix/X663/proprietary/overlay/FrameworkResOverlay/FrameworkResOverlay.apk:$(TARGET_COPY_OUT_VENDOR)/overlay/FrameworkResOverlay/FrameworkResOverlay.apk \
    ,$(PRODUCT_COPY_FILES))

# Stock FrameworkResOverlay is Transsion-specific; do not install it.

# Use the same AVB-relaxed fstab for vendor and first stage.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6768

# Framework resource overlay
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# Virtual A/B
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch.mk)
PRODUCT_VIRTUAL_AB_COMPRESSION := true

# snapuserd is a single module in AOSP 12.
PRODUCT_PACKAGES += \
    snapuserd

PRODUCT_SHIPPING_API_LEVEL := 30
PRODUCT_CHARACTERISTICS := phone

# The stock vendor tree is VNDK 31. AOSP 12 uses v31 as current; 12L uses
# v32, so install the v31 snapshot for 12L builds.
ifeq ($(PLATFORM_SDK_VERSION),32)
PRODUCT_EXTRA_VNDK_VERSIONS := 31
PRODUCT_VENDOR_PROPERTIES += ro.vndk.version=31
endif

# Keep the stock vendor policy; do not let AOSP replace it.
PRODUCT_PRECOMPILED_SEPOLICY := false

# AOSP packages that would overwrite stock vendor files.
PRODUCT_PACKAGES := $(filter-out \
    selinux_policy_nonsystem \
    vendor_compatibility_matrix.xml \
    android.hardware.cas@1.2-service \
    android.hardware.media.omx@1.0-service \
    audio.primary.default \
    boringssl_self_test_vendor \
    dumpsys_vendor \
    applypatch \
    gralloc.default \
    libaudiopreprocessing \
    local_time.default \
    power.default \
    shell_and_utilities_vendor \
    vibrator.default \
    libbundlewrapper \
    libclearkeycasplugin \
    libdownmix \
    libdrmclearkeyplugin \
    libdynproc \
    libeffectproxy \
    libeffects \
    libhapticgenerator \
    libldnhncr \
    libreference-ril \
    libreverbwrapper \
    libril \
    libvisualizer \
    ,$(PRODUCT_PACKAGES))

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
    mtk-plpath-utils.rc

# Plain AOSP 12 has no kernel.mk; copy Image.gz ourselves (Lineage re-adds it).
ifeq ($(wildcard vendor/lineage/build/tasks/kernel.mk),)
PRODUCT_COPY_FILES += \
    kernel/infinix/X663/Image.gz:kernel
endif

# First-boot debug logging (userdebug/eng); remove after first boot.
include $(LOCAL_PATH)/debug/debug-bootloop.mk
