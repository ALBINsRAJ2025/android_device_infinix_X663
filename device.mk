# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2026 ALBINsRAJ2025
#
# device.mk - Infinix Note 11 (X663)
#

LOCAL_PATH := device/infinix/X663

# Stock vendor payload
$(call inherit-product, vendor/infinix/X663/X663-vendor.mk)

# The stock vendor tree carries empty fs_config, passwd and group files.
# Keep the platform-generated copies so the ownership and mode data from
# configs/fs_config is available to the image builder and to libcutils.
PRODUCT_COPY_FILES := $(filter-out \
    vendor/infinix/X663/proprietary/etc/fs_config_files:vendor/etc/fs_config_files \
    vendor/infinix/X663/proprietary/etc/fs_config_dirs:vendor/etc/fs_config_dirs \
    vendor/infinix/X663/proprietary/etc/passwd:vendor/etc/passwd \
    vendor/infinix/X663/proprietary/etc/group:vendor/etc/group \
    vendor/infinix/X663/proprietary/odm/etc/passwd:vendor/odm/etc/passwd \
    vendor/infinix/X663/proprietary/odm/etc/group:vendor/odm/etc/group \
    vendor/infinix/X663/proprietary/etc/fstab.mt6768:vendor/etc/fstab.mt6768 \
    frameworks/native/data/etc/handheld_core_hardware.xml:vendor/etc/permissions/handheld_core_hardware.xml \
    vendor/infinix/X663/proprietary/overlay/FrameworkResOverlay/FrameworkResOverlay.apk:vendor/overlay/FrameworkResOverlay/FrameworkResOverlay.apk \
    ,$(PRODUCT_COPY_FILES))

# The stock FrameworkResOverlay is written for the Transsion framework. It
# points config_dozeComponent at com.transsion.aod and uses Transsion-only
# resource names. The device overlay below carries the equivalent AOSP values,
# so do not install the vendor RRO that would override them at runtime.

# The stock vendor init reads /vendor/etc/fstab.mt6768 during the early and
# late mount phases. Use the same AVB-relaxed fstab as the first-stage ramdisk
# so both mount passes agree.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6768

# Framework resource overlay
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# Virtual A/B with snapshots and compression
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch.mk)
PRODUCT_VIRTUAL_AB_COMPRESSION := true

# AOSP 12's libsnapshot defines a single snapuserd module with ramdisk,
# vendor_ramdisk and recovery availability; snapuserd.ramdisk and
# snapuserd.recovery are install-path labels, not module names. The
# first-stage copy is handled by the recovery-as-boot packaging below.
PRODUCT_PACKAGES += \
    snapuserd

PRODUCT_SHIPPING_API_LEVEL := 30
PRODUCT_CHARACTERISTICS := phone

# The stock vendor tree is VNDK 31. AOSP 12 uses v31 as current; 12L uses
# v32, so install the v31 snapshot for 12L builds.
ifeq ($(PLATFORM_SDK_VERSION),32)
PRODUCT_EXTRA_VNDK_VERSIONS := 31
endif

# The vendor tree installs the stock vendor policy, context files and
# precompiled policy. Disable AOSP's precompiled policy and filter the AOSP
# vendor policy package; otherwise it regenerates platform-only files over
# the stock policy.
PRODUCT_PRECOMPILED_SEPOLICY := false

# These platform vendor packages would overwrite binaries, libraries or
# metadata supplied by the stock vendor tree.
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

# First-stage fstab for recovery-as-boot
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_RAMDISK)/fstab.mt6768
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

# Prebuilt kernel for plain AOSP 12 trees.
#
# AOSP 12 removed build/make/core/tasks/kernel.mk, so TARGET_PREBUILT_KERNEL
# (set in BoardConfig.mk) has no consumer there and $(PRODUCT_OUT)/kernel is
# never created. LineageOS 19.1 re-adds kernel.mk through its build fork and
# owns that target, so the copy file is only added when kernel.mk is absent.
# Keeping one producer avoids a duplicate rule for $(PRODUCT_OUT)/kernel.
ifeq ($(wildcard vendor/lineage/build/tasks/kernel.mk),)
PRODUCT_COPY_FILES += \
    kernel/infinix/X663/Image.gz:kernel
endif

# First-boot debug logging for the X663 (userdebug/eng only).
# Remove this include, or set X663_DEBUG_BOOTLOOP := false before it, once the
# device reaches the home screen.  See debug/debug-bootloop.mk.
include $(LOCAL_PATH)/debug/debug-bootloop.mk
