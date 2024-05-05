#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_VERSION:=2023.04
PKG_RELEASE:=1

PKG_HASH:=e31cac91545ff41b71cec5d8c22afd695645cd6e2a442ccdacacd60534069341

PKG_MAINTAINER:=Tobias Maedel <openwrt@tbspace.de>

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk
include ../arm-trusted-firmware-rockchip/atf-version.mk

define U-Boot/Default
  BUILD_TARGET:=rockchip
  UENV:=default
  HIDDEN:=1
endef


# RK3328 boards

define U-Boot/Default/rk3328
  BUILD_SUBTARGET:=armv8
  DEPENDS:=+PACKAGE_u-boot-$(1):trusted-firmware-a-rk3328
  ATF:=$(RK3328_ATF)
endef

define U-Boot/nanopi-r2s-rk3328
  $(U-Boot/Default/rk3328)
  NAME:=NanoPi R2S
  BUILD_DEVICES:= \
    friendlyarm_nanopi-r2s
endef


# RK3399 boards

define U-Boot/Default/rk3399
  BUILD_SUBTARGET:=armv8
  DEPENDS:=+PACKAGE_u-boot-$(1):trusted-firmware-a-rk3399
  ATF:=$(RK3399_ATF)
endef

define U-Boot/nanopi-r4s-rk3399
  $(U-Boot/Default/rk3399)
  NAME:=NanoPi R4S
  BUILD_DEVICES:= \
    friendlyarm_nanopi-r4s
endef

define U-Boot/rock-pi-4-rk3399
  $(U-Boot/Default/rk3399)
  NAME:=Rock Pi 4
  BUILD_DEVICES:= \
    radxa_rock-pi-4a
endef

define U-Boot/rockpro64-rk3399
  $(U-Boot/Default/rk3399)
  NAME:=RockPro64
  BUILD_DEVICES:= \
    pine64_rockpro64
endef


# RK3568 boards

define U-Boot/Default/rk3568
  BUILD_SUBTARGET:=armv8
  DEPENDS:=+PACKAGE_u-boot-$(1):trusted-firmware-a-rk3568
  ATF:=$(RK3568_ATF)
  DDR:=$(RK3568_DDR)
endef

define U-Boot/nanopi-r5c-rk3568
  $(U-Boot/Default/rk3568)
  NAME:=FriendlyARM NanoPi R5C
  BUILD_DEVICES:= \
    friendlyarm_nanopi-r5c
endef

define U-Boot/nanopi-r5s-rk3568
  $(U-Boot/Default/rk3568)
  NAME:=FriendlyARM NanoPi R5S
  BUILD_DEVICES:= \
    friendlyarm_nanopi-r5s
endef


UBOOT_TARGETS := \
  nanopi-r4s-rk3399 \
  rock-pi-4-rk3399 \
  rockpro64-rk3399 \
  nanopi-r2s-rk3328 \
  nanopi-r5c-rk3568 \
  nanopi-r5s-rk3568

UBOOT_CONFIGURE_VARS += USE_PRIVATE_LIBGCC=yes

UBOOT_MAKE_FLAGS += \
  PATH=$(STAGING_DIR_HOST)/bin:$(PATH) \
  BL31=$(STAGING_DIR_IMAGE)/$(ATF) \
  $(if $(DDR),ROCKCHIP_TPL=$(STAGING_DIR_IMAGE)/$(DDR))

define Build/Configure
	$(call Build/Configure/U-Boot)
	$(SED) 's#CONFIG_MKIMAGE_DTC_PATH=.*#CONFIG_MKIMAGE_DTC_PATH="$(PKG_BUILD_DIR)/scripts/dtc/dtc"#g' $(PKG_BUILD_DIR)/.config
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
ifneq ($(DDR),)
	$(CP) $(PKG_BUILD_DIR)/idbloader.img $(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-idbloader.img
	$(CP) $(PKG_BUILD_DIR)/u-boot.itb $(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-u-boot.itb
else
	$(STAGING_DIR_IMAGE)/loaderimage --pack --uboot $(PKG_BUILD_DIR)/u-boot-dtb.bin $(PKG_BUILD_DIR)/uboot.img 0x200000
	$(CP) $(PKG_BUILD_DIR)/uboot.img $(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-uboot.img
endif
endef

define Package/u-boot/install/default
endef

$(eval $(call BuildPackage/U-Boot))
