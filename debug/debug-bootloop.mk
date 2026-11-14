# SPDX-License-Identifier: Apache-2.0
#
# X663 first-boot debug configuration.
#
# Purpose:
#   * adbd runs at boot without an RSA prompt (userdebug/eng only)
#   * logd starts in AOSP init.rc "on init", before every other service
#   * logd also collects the kernel ring buffer (ro.logd.kernel=true)
#   * a root logcat follower starts in "on init" (the same trigger that starts
#     logd) and writes all buffers continuously to /metadata, which is a
#     first_stage_mount and survives a reboot that never reaches /data or the
#     home screen
#
# This file is included once from device.mk.  It is intentionally a no-op on
# user builds: "su" is only permissive on userdebug/eng, which is also the
# only variant where auto-approved adb is acceptable.
#
# REMOVAL (after the first successful boot to the home screen):
#   Remove the "include $(LOCAL_PATH)/debug/debug-bootloop.mk" line from
#   device.mk, or set X663_DEBUG_BOOTLOOP := false before that include.
#   Nothing in vendor.prop, BoardConfig.mk or the stock blobs is modified.

X663_DEBUG_BOOTLOOP ?= true

ifeq ($(X663_DEBUG_BOOTLOOP),true)
ifneq ($(filter userdebug eng,$(TARGET_BUILD_VARIANT)),)

# product/etc/build.prop is loaded after vendor/build.prop, so these values
# override the stock vendor.prop entries (ro.logd.kernel=false and
# persist.sys.usb.config=none).  Two of these keys also exist in vendor.prop
# on purpose; the remaining three are new defaults.
PRODUCT_PRODUCT_PROPERTIES += \
    ro.adb.secure=0 \
    ro.logd.kernel=true \
    ro.logd.size=1M \
    ro.logd.size.kernel=1M \
    persist.sys.usb.config=adb

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/debug/x663-logd.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/x663-logd.rc \
    $(LOCAL_PATH)/debug/x663-logd.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/x663-logd.sh \
    $(LOCAL_PATH)/debug/x663-logreport.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/x663-logreport.sh

endif
endif
