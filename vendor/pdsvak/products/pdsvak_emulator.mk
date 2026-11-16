# PD-SVAK on the Android emulator (x86_64), built from the GrapheneOS tree.
# For fast testing of our layer (overlays, branding, preinstalled apps) without a phone.
# Not a security target: the emulator has no verified boot, no hardware keystore and no MTE.
# Usage: build/emulator.sh build | run

# Same as stock sdk_phone64_x86_64, which relaxes this only for its own product name.
PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := relaxed

$(call inherit-product, device/generic/goldfish/64bitonly/product/sdk_phone64_x86_64.mk)
$(call inherit-product, vendor/pdsvak/pdsvak.mk)

PRODUCT_NAME := pdsvak_emulator
PRODUCT_MODEL := PD-SVAK emulator (x86_64)
