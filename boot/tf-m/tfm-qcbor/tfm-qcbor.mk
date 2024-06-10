################################################################################
#
# qcbor
#
################################################################################

TFM_QCBOR_SITE = $(call qstrip,$(BR2_TARGET_TFM_QCBOR_GIT_REPO_URL))
TFM_QCBOR_VERSION = $(call qstrip,$(BR2_TARGET_TFM_QCBOR_GIT_REPO_VERSION))
TFM_QCBOR_SITE_METHOD = git
TFM_QCBOR_LICENSE = BSD-3-Clause
TFM_QCBOR_LICENSE_FILES = README.md

ifeq ($(BR2_TARGET_TF_M):$(BR2_TARGET_TF_M_LATEST_VERSION),y:)
BR_NO_CHECK_HASH_FOR += $(TFM_QCBOR_SOURCE)
endif

# This components is not built and installed, because it is intended to
# be included as source in TrustedFirmware-M build.

$(eval $(generic-package))
