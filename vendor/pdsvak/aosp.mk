# PD-SVAK product layer for the AOSP line (LineageOS-based Silver/Bronze devices).
# LineageOS's vendor/lineage/config/common.mk inherits vendor/extra/product.mk if it exists;
# build/aosp-sync.sh writes that file to inherit this one, so no LineageOS patch is needed.

# Same branding, privacy defaults and preinstalled apps as the Gold line.
$(call inherit-product, vendor/pdsvak/pdsvak.mk)

# LineageOS's Updater would otherwise offer official LineageOS builds over ours.
# Point it at our server (lineage.updater.uri overrides its built-in URL).
PRODUCT_SYSTEM_PROPERTIES += \
    lineage.updater.uri=https://updates.pdsvak.example/aosp/{device}/
