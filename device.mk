#
# device.mk - Infinix Note 11 (X663)
#

LOCAL_PATH := device/infinix/X663

# Stock vendor payload
$(call inherit-product, vendor/infinix/X663/X663-vendor.mk)

# The stock vendor image carries empty fs_config, passwd and group files.
# Keep the platform-generated copies so the ownership and mode data from
# configs/fs_config is available to the image builder and to libcutils.
PRODUCT_COPY_FILES := $(filter-out \
    vendor/infinix/X663/proprietary/etc/fs_config_files:vendor/etc/fs_config_files \
    vendor/infinix/X663/proprietary/etc/fs_config_dirs:vendor/etc/fs_config_dirs \
    vendor/infinix/X663/proprietary/etc/passwd:vendor/etc/passwd \
    vendor/infinix/X663/proprietary/etc/group:vendor/etc/group \
    vendor/infinix/X663/proprietary/odm/etc/passwd:vendor/odm/etc/passwd \
    vendor/infinix/X663/proprietary/odm/etc/group:vendor/odm/etc/group \
    ,$(PRODUCT_COPY_FILES))

# Framework resource overlay
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# Virtual A/B with snapshots and compression
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch.mk)
PRODUCT_VIRTUAL_AB_COMPRESSION := true

PRODUCT_PACKAGES += \
    snapuserd \
    snapuserd.ramdisk \
    snapuserd.recovery

PRODUCT_SHIPPING_API_LEVEL := 30
PRODUCT_CHARACTERISTICS := phone

# The stock vendor image is VNDK 31. AOSP 12 uses v31 as current; 12L uses
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
    android.hardware.media.omx@1.0-service \
    boringssl_self_test_vendor \
    dumpsys_vendor \
    applypatch \
    gralloc.default \
    shell_and_utilities_vendor \
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

# System properties
TARGET_SYSTEM_PROP := $(LOCAL_PATH)/system.prop
