################################################################################
#
# TrustedFirmware-M
#
################################################################################

TF_M_VERSION = $(call qstrip,$(BR2_TARGET_TF_M_VERSION))

ifeq ($(BR2_TARGET_TF_M_CUSTOM_TARBALL),y)
# Handle custom FT-M tarballs as specified by the configuration
TF_M_TARBALL = $(call qstrip,$(BR2_TARGET_TF_M_CUSTOM_TARBALL_LOCATION))
TF_M_SITE = $(patsubst %/,%,$(dir $(TF_M_TARBALL)))
TF_M_SOURCE = $(notdir $(TF_M_TARBALL))
else ifeq ($(BR2_TARGET_TF_M_CUSTOM_GIT),y)
TF_M_SITE = $(call qstrip,$(BR2_TARGET_TF_M_CUSTOM_REPO_URL))
TF_M_SITE_METHOD = git
else
# Handle stable official TF-M versions
TF_M_SITE = https://git.trustedfirmware.org/TF-M/trusted-firmware-m.git
TF_M_SITE_METHOD = git
# The licensing of custom or from-git versions is unknown
# This is valid only for the latest (i.e. known) version
ifeq ($(BR2_TARGET_TF_M_LATEST_VERSION),y)
TF_M_LICENSE = BSD-3-Clause, Apache-2.0, GPL-2.0-or-later
TF_M_LICENSE_FILES = license.rst
endif
endif

ifeq ($(BR2_TARGET_TF_M):$(BR2_TARGET_TF_M_LATEST_VERSION),y:)
BR_NO_CHECK_HASH_FOR += $(TF_M_SOURCE)
endif

TF_M_DEPENDENCIES += \
	$(BR2_CMAKE_HOST_DEPENDENCY) \
	host-arm-gnu-toolchain \
	host-python-cbor2 \
	host-python-click \
	host-python-cryptography \
	host-python-jinja2 \
	host-python-intelhex \
	host-python-pyyaml

TF_M_PATCH_DEPENDENCIES += \
	tfm-mbedtls \
	tfm-mcuboot \
	tfm-qcbor \
	tfm-cmsis

define TF_M_PATCH_3RD_PARTIES
	if [ -d $(@D)/lib/ext/cmsis ] && [ ! -s $(TFM_CMSIS_SRCDIR).applied_patches_list ]; then \
		$(APPLY_PATCHES) $(TFM_CMSIS_SRCDIR) $(@D)/lib/ext/cmsis \*.patch; \
	fi
	if [ -d $(@D)/lib/ext/mbedcrypto ] && [ ! -s $(TFM_MBEDTLS_SRCDIR).applied_patches_list ]; then \
		$(APPLY_PATCHES) $(TFM_MBEDTLS_SRCDIR) $(@D)/lib/ext/mbedcrypto \*.patch; \
	fi
	if [ -d $(@D)/lib/ext/mcuboot ] && [ ! -s $(TFM_MCUBOOT_SRCDIR).applied_patches_list ]; then \
		$(APPLY_PATCHES) $(TFM_MCUBOOT_SRCDIR) $(@D)/lib/ext/mcuboot \*.patch; \
	fi
	if [ -d $(@D)/lib/ext/qcbor ] && [ ! -s $(TFM_QCBOR_SRCDIR).applied_patches_list ]; then \
		$(APPLY_PATCHES) $(TFM_QCBOR_SRCDIR) $(@D)/lib/ext/qcbor \*.patch; \
	fi
endef
TF_M_POST_PATCH_HOOKS += TF_M_PATCH_3RD_PARTIES

TF_M_CONF_OPTS += \
	-DFETCHCONTENT_FULLY_DISCONNECTED=ON \
	-DCROSS_COMPILE=$(HOST_DIR)/bin/arm-none-eabi \
	-DMBEDCRYPTO_PATH=$(TFM_MBEDTLS_SRCDIR) \
	-DMCUBOOT_PATH=$(TFM_MCUBOOT_SRCDIR) \
	-DQCBOR_PATH=$(TFM_QCBOR_SRCDIR) \
	-DCMSIS_PATH=$(TFM_CMSIS_SRCDIR) \
	-DTFM_PLATFORM=$(call qstrip,$(BR2_TARGET_TF_M_PLATFORM))

define TF_M_CONFIGURE_CMDS
	rm -f $(@D)/CMakeCache.txt
	PATH=$(BR_PATH) \
	$(BR2_CMAKE) -S $(@D) -B $(@D) \
		$(TF_M_CONF_OPTS) \
		$(call qstrip,$(BR2_TARGET_TF_M_ADDITIONAL_VARIABLES))
endef

define TF_M_BUILD_CMDS
	PATH=$(BR_PATH) \
	$(BR2_CMAKE) --build $(@D) -- install
endef

define TF_M_INSTALL_TARGET_CMDS
	mkdir -p $(BINARIES_DIR)/tf-m
	$(INSTALL) -D -m 0755 $(@D)/api_ns/bin/*.bin $(BINARIES_DIR)/tf-m
	$(INSTALL) -D -m 0755 $(@D)/api_ns/bin/*.elf $(BINARIES_DIR)/tf-m
endef

# Configuration check
ifeq ($(BR2_TARGET_TF_M)$(BR_BUILDING),yy)

ifeq ($(BR2_TARGET_TF_M_CUSTOM_TARBALL),y)
ifeq ($(call qstrip,$(BR2_TARGET_TF_M_CUSTOM_TARBALL_LOCATION)),)
$(error No tarball location specified. Please check BR2_TARGET_TF_M_CUSTOM_TARBALL_LOCATION)
endif
endif

ifeq ($(BR2_TARGET_TF_M_CUSTOM_GIT),y)
ifeq ($(call qstrip,$(BR2_TARGET_TF_M_CUSTOM_REPO_URL)),)
$(error No repository specified. Please check BR2_TARGET_TF_M_CUSTOM_REPO_URL)
endif
endif

endif

$(eval $(generic-package))
include $(sort $(wildcard boot/tf-m/*/*.mk))
