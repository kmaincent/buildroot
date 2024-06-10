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
# The licensing of custom or from-git versions is unknown.
# This is valid only for the latest (i.e. known) version.
ifeq ($(BR2_TARGET_TF_M_LATEST_VERSION),y)
TF_M_LICENSE = BSD-3-Clause, Apache-2.0, GPL-2.0-or-later
TF_M_LICENSE_FILES = \
	license.rst \
	3rd_parties/cmsis/LICENSE \
	3rd_parties/mbedcrypto/LICENSE \
	3rd_parties/mcuboot/LICENSE \
	3rd_parties/mcuboot/README.md
endif
endif

ifeq ($(BR3_TARGET_TF_M):$(BR2_TARGET_TF_M_LATEST_VERSION),y:)
BR_NO_CHECK_HASH_FOR += $(TF_M_SOURCE)
endif

# Use mbedcrypto naming from TF-M instead of mbedtl to 3rd parties management
TF_M_MBEDCRYPTO_TARBALL = $(call qstrip,$(BR2_TARGET_TF_M_MBEDTLS_TARBALL_LOCATION))
TF_M_MCUBOOT_TARBALL = $(call qstrip,$(BR2_TARGET_TF_M_MCUBOOT_TARBALL_LOCATION))
TF_M_CMSIS_TARBALL = $(call qstrip,$(BR2_TARGET_TF_M_CMSIS_TARBALL_LOCATION))
TF_M_QCBOR_TARBALL = $(call qstrip,$(BR2_TARGET_TF_M_QCBOR_TARBALL_LOCATION))
TF_M_EXTRA_DOWNLOADS += \
	$(TF_M_MBEDCRYPTO_TARBALL) \
	$(TF_M_MCUBOOT_TARBALL) \
	$(TF_M_CMSIS_TARBALL) \
	$(TF_M_QCBOR_TARBALL)

TF_M_DEPENDENCIES += \
	$(BR2_CMAKE_HOST_DEPENDENCY) \
	host-arm-gnu-toolchain \
	host-python-cbor2 \
	host-python-click \
	host-python-cryptography \
	host-python-jinja2 \
	host-python-intelhex \
	host-python-pyyaml

TF_M_3RD_PARTIES = mbedcrypto mcuboot cmsis qcbor

define TF_M_EXTRACT_3RD_PARTIES
	$(foreach f, $(TF_M_3RD_PARTIES), \
		mkdir -p $(@D)/3rd_parties/$(f) ; \
		$(call suitable-extractor,$(notdir $(TF_M_$(call UPPERCASE,$(f))_TARBALL))) \
		$(TF_M_DL_DIR)/$(notdir $(TF_M_$(call UPPERCASE,$(f))_TARBALL)) | \
		$(TAR) --strip-components=1 -C $(@D)/3rd_parties/$(f) $(TAR_OPTIONS) -
	)
endef
TF_M_POST_EXTRACT_HOOKS += TF_M_EXTRACT_3RD_PARTIES

define TF_M_PATCH_3RD_PARTIES
	$(foreach f, $(TF_M_3RD_PARTIES), \
		if [ -d $(@D)/lib/ext/$(f) ]; then \
			$(APPLY_PATCHES) $(@D)/3rd_parties/$(f) $(@D)/lib/ext/$(f) \*.patch; \
		fi;
	)
endef
TF_M_POST_PATCH_HOOKS += TF_M_PATCH_3RD_PARTIES

TF_M_CONF_OPTS += \
	-DCMAKE_TOOLCHAIN_FILE="$(HOST_DIR)/share/buildroot/toolchainfile.cmake" \
	-DFETCHCONTENT_FULLY_DISCONNECTED=ON \
	-DMBEDCRYPTO_PATH=$(@D)/3rd_parties/mbedcrypto \
	-DMCUBOOT_PATH=$(@D)/3rd_parties/mcuboot \
	-DQCBOR_PATH=$(@D)/3rd_parties/qcbor \
	-DCMSIS_PATH=$(@D)/3rd_parties/cmsis \
	-DTFM_PLATFORM=$(call qstrip,$(BR2_TARGET_TF_M_PLATFORM))

ifeq ($(BR2_TARGET_TF_M_DEBUG),y)
TF_M_CONF_OPTS += -DCMAKE_BUILD_TYPE=Debug
endif

TF_M_CONF_ENV += \
	CROSS_COMPILE=$(HOST_DIR)/bin/arm-none-eabi-

define TF_M_CONFIGURE_CMDS
	rm -f $(@D)/CMakeCache.txt
	PATH=$(BR_PATH) \
	$(TF_M_CONF_ENV) $(BR2_CMAKE) -S $(@D) -B $(@D) \
		$(TF_M_CONF_OPTS) \
		$(call qstrip,$(BR2_TARGET_TF_M_ADDITIONAL_VARIABLES))
endef

define TF_M_BUILD_CMDS
	PATH=$(BR_PATH) \
	$(TF_M_CONF_ENV) $(BR2_CMAKE) \
		--build $(@D) -- install
endef

define TF_M_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/api_ns/bin/*.bin $(BINARIES_DIR); \
	$(INSTALL) -D -m 0755 $(@D)/api_ns/bin/*.elf $(BINARIES_DIR); \
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
