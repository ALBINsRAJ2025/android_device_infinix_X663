$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)
$(call inherit-product, device/infinix/X663/device.mk)
$(call inherit-product, vendor/infinix/X663/vendor.mk)

$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_DEVICE := X663
PRODUCT_NAME := lineage_X663
PRODUCT_BRAND := Infinix
PRODUCT_MANUFACTURER := Infinix
PRODUCT_MODEL := Infinix X663
TARGET_SCREEN_DENSITY := 480

PRODUCT_SHIPPING_API_LEVEL := 30
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION := false

PRODUCT_COPY_FILES += \
	device/infinix/X663/configs/permissions/privapp-permissions-mediatek.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-mediatek.xml
