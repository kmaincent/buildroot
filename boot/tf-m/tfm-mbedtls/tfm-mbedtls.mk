################################################################################
#
# mbedtls
#
################################################################################

TFM_MBEDTLS_SITE = $(call qstrip,$(BR2_TARGET_TFM_MBEDTLS_GIT_REPO_URL))
TFM_MBEDTLS_VERSION = $(call qstrip,$(BR2_TARGET_TFM_MBEDTLS_GIT_REPO_VERSION))
TFM_MBEDTLS_SITE_METHOD = git
TFM_MBEDTLS_GIT_SUBMODULES = YES
TFM_MBEDTLS_LICENSE = Apache-2.0 or GPL-2.0-or-later
TFM_MBEDTLS_LICENSE_FILES = LICENSE

ifeq ($(BR2_TARGET_TF_M):$(BR2_TARGET_TF_M_LATEST_VERSION),y:)
BR_NO_CHECK_HASH_FOR += $(TFM_MBEDTLS_SOURCE)
endif

# This components is not built and installed, because it is intended to
# be included as source in TrustedFirmware-M build.

$(eval $(generic-package))
