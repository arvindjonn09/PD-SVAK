# PD-SVAK product layer. Inherited by every Gold-line device product:
#   $(call inherit-product-if-exists, vendor/pdsvak/pdsvak.mk)
# That one include line is our only change to the device makefiles. It is carried as a patch
# (see vendor/pdsvak/README.md). Everything else lives here, so monthly rebases stay small.

PDS_VENDOR := vendor/pdsvak

# --- Branding -------------------------------------------------------------------------------
PRODUCT_PRODUCT_PROPERTIES += \
    ro.pdsvak.name=PD-SVAK \
    ro.pdsvak.channel=$(if $(PDS_CHANNEL),$(PDS_CHANNEL),beta) \
    ro.pdsvak.security_tier=$(if $(PDS_SECURITY_TIER),$(PDS_SECURITY_TIER),gold)

ifneq ($(wildcard $(PDS_VENDOR)/bootanimation/bootanimation.zip),)
PRODUCT_COPY_FILES += $(PDS_VENDOR)/bootanimation/bootanimation.zip:$(TARGET_COPY_OUT_PRODUCT)/media/bootanimation.zip
endif

# --- Privacy defaults (static overlays on framework/system resources) ---------------------
# Every resource name overlaid here is checked against the synced tree by
# build/check-overlays.sh, which fails if upstream renamed or removed it.
PRODUCT_PACKAGE_OVERLAYS += $(PDS_VENDOR)/overlay

# --- Preinstalled apps -----------------------------------------------------------------------
# APKs are not in git. build/fetch-prebuilts.sh downloads them and checks the pinned SHA-256
# in vendor/pdsvak/prebuilts.lock before the build.
PRODUCT_PACKAGES += \
    Accrescent
