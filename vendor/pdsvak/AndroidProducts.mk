# PD-SVAK's own products. Device products (Pixels, AOSP-line phones) are defined upstream and
# pick up our layer through a hook instead; see pdsvak.mk and aosp.mk.
PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/products/pdsvak_emulator.mk
