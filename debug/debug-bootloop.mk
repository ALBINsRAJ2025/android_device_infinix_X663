# SPDX-License-Identifier: Apache-2.0
#
# X663 first-boot debug configuration (userdebug/eng only, no-op on user).
# Remove the include in device.mk or set X663_DEBUG_BOOTLOOP := false once the
# device boots to the home screen.  Nothing in vendor.prop/BoardConfig.mk or
# the stock blobs is modified.

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
    $(LOCAL_PATH)/debug/x663-logmirror.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/x663-logmirror.sh \
    $(LOCAL_PATH)/debug/x663-logreport.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/x663-logreport.sh

endif
endif
