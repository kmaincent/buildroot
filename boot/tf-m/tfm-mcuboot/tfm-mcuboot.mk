################################################################################
#
# mcuboot
#
################################################################################

TFM_MCUBOOT_SITE = $(call qstrip,$(BR2_TARGET_TFM_MCUBOOT_GIT_REPO_URL))
TFM_MCUBOOT_VERSION = $(call qstrip,$(BR2_TARGET_TFM_MCUBOOT_GIT_REPO_VERSION))
TFM_MCUBOOT_SITE_METHOD = git
TFM_MCUBOOT_LICENSE = Apache-2.0
TFM_MCUBOOT_LICENSE_FILES = LICENSE

ifeq ($(BR2_TARGET_TF_M):$(BR2_TARGET_TF_M_LATEST_VERSION),y:)
BR_NO_CHECK_HASH_FOR += $(TFM_MCUBOOT_SOURCE)
endif

# This components is not built and installed, because it is intended to
# be included as source in TrustedFirmware-M build.

$(eval $(generic-package))
