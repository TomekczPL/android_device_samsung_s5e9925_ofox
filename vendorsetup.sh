#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 The TWRP Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# For building with minimal manifest
export ALLOW_MISSING_DEPENDENCIES=true

# Persist OFRP settings on /cache (S22 has no /data decryption in recovery)
export FOX_SETTINGS_ROOT_DIRECTORY="/cache/OFRP"
export FOX_MISCELLANEOUS_ROOT_DIRECTORY="/cache/OFRP"
