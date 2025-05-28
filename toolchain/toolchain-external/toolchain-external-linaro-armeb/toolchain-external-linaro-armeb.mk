################################################################################
#
# toolchain-external-linaro-armeb
#
################################################################################

TOOLCHAIN_EXTERNAL_LINARO_ARMEB_VERSION = 2018.05

TOOLCHAIN_EXTERNAL_LINARO_ARMEB_SITE = https://releases.linaro.org/components/toolchain/binaries/7.3-$(TOOLCHAIN_EXTERNAL_LINARO_ARMEB_VERSION)/armeb-linux-gnueabihf

ifeq ($(HOSTARCH),x86)
TOOLCHAIN_EXTERNAL_LINARO_ARMEB_SOURCE = gcc-linaro-7.3.1-$(TOOLCHAIN_EXTERNAL_LINARO_ARMEB_VERSION)-i686_armeb-linux-gnueabihf.tar.xz
else
TOOLCHAIN_EXTERNAL_LINARO_ARMEB_SOURCE = gcc-linaro-7.3.1-$(TOOLCHAIN_EXTERNAL_LINARO_ARMEB_VERSION)-x86_64_armeb-linux-gnueabihf.tar.xz
endif
TOOLCHAIN_EXTERNAL_LINARO_ARMEB_LICENSE = multiple
TOOLCHAIN_EXTERNAL_LINARO_ARMEB_LICENSE_FILES = \
	share/info/annotate.info \
	share/info/as.info \
	share/info/bfd.info \
	share/info/binutils.info \
	share/info/cpp.info \
	share/info/cppinternals.info \
	share/info/gcc.info \
	share/info/gccinstall.info \
	share/info/gccint.info \
	share/info/gdb.info \
	share/info/gfortran.info \
	share/info/gmp.info \
	share/info/gmp.info-1 \
	share/info/gmp.info-2 \
	share/info/gprof.info \
	share/info/ld.info \
	share/info/libgomp.info \
	share/info/libitm.info \
	share/info/mpc.info \
	share/info/mpfr.info \
	share/info/stabs.info

$(eval $(toolchain-external-package))
