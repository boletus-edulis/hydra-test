{ src
, pkgs
, lib
, ...
}:
pkgs.linux_6_7.override {
  argsOverride = {
    inherit src;
    modDirVersion = lib.versions.pad 3 pkgs.linux_6_7.version;
    #modDirVersion = "6.7.1";
    defconfig = "laptop_defconfig";
    #defconfig = "johan_defconfig";
    structuredExtraConfig = with lib.kernel; {
      VIDEO_AR1337 = no;
      AUDIT = yes;
      ARM64_SME = yes;
      MAC80211_LEDS = yes;
      FW_LOADER_USER_HELPER = yes;
      QCOM_EBI2 = yes;
      EFI_CAPSULE_LOADER = yes;
      SRAM = yes;
      KEYBOARD_GPIO = yes;
      SERIAL_QCOM_GENI = yes;
      PINCTRL_QCOM_SPMI_PMIC = yes;
      PINCTRL_SC8280XP_LPASS_LPI = module;
      QCOM_TSENS = yes;
      BACKLIGHT_CLASS_DEVICE = yes;
      VIRTIO_MENU = yes;
      VHOST_MENU = yes;
      SC_GCC_8280XP = yes;
      SC_GPUCC_8280XP = yes;
      QCOM_Q6V5_ADSP = module;
      QCOM_STATS = yes;
      QCOM_CPR = yes;
      QCOM_RPMHPD = yes;
      QCOM_RPMPD = yes;
      PHY_QCOM_QMP_PCIE_8996 = yes;
      NVMEM_QCOM_QFPROM = yes;
      CRYPTO_AES_ARM64_CE_BLK = yes;
      CRYPTO_AES_ARM64_BS = yes;
      CRYPTO_AES_ARM64_CE_CCM = yes;
      CONFIG_CRYPTO_DEV_CCREE = module;
    };
  };
}
