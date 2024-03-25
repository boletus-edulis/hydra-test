{ src
, pkgs
, lib
, linuxManualConfig
, ...
}:
let
  linux = pkgs.linux_6_7;
  modDirVersion = "$(cat $(pwd)/build/include/config/kernel.release)";
in
#linux.override {
#  argsOverride = {
#    inherit src;
#    modDirVersion = "6.7.10";
#    # inherit modDirVersion;
#    #"6.8.1";
#    defconfig = "laptop_defconfig";
#    structuredExtraConfig = with lib.kernel; {
#      VIDEO_AR1337 = no;
#      AUDIT = yes;
#      ARM64_SME = yes;
#      MAC80211_LEDS = yes;
#      FW_LOADER_USER_HELPER = yes;
#      QCOM_EBI2 = yes;
#      EFI_CAPSULE_LOADER = yes;
#      SRAM = yes;
#      KEYBOARD_GPIO = yes;
#      SERIAL_QCOM_GENI = yes;
#      PINCTRL_QCOM_SPMI_PMIC = yes;
#      BACKLIGHT_CLASS_DEVICE = yes;
#      VIRTIO_MENU = yes;
#      VHOST_MENU = yes;
#      SC_GCC_8280XP = yes;
#      SC_GPUCC_8280XP = yes;
#      QCOM_CPR = yes;
#      NVMEM_QCOM_QFPROM = yes;
#      CRYPTO_AES_ARM64_CE_BLK = yes;
#      CRYPTO_AES_ARM64_BS = yes;
#      CRYPTO_AES_ARM64_CE_CCM = yes;
#
#      #QCOM_RPMPD = module;
#      #QCOM_TSENS = module;
#      #QCOM_STATS = module;
#      #QCOM_RPMHPD = module;
#      #QCOM_Q6V5_ADSP = module;
#      #PHY_QCOM_QMP_PCIE_8996 = module;
#      #PINCTRL_SC8280XP_LPASS_LPI = module;
#    };
#  };
#}
linuxManualConfig {
  inherit (linux) version;
  inherit src;
  configfile = ./laptop_defconfig;
}
