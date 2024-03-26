{ src
, pkgs
, lib
, stdenv
, linuxManualConfig
, ...
} @ args:
let
  linux = pkgs.linux_6_7;
  modDirVersion = "6.7.10"; #"$(cat $(pwd)/build/include/config/kernel.release)";
in
linux.override {
  argsOverride = {
    inherit src;
    #modDirVersion = "6.7.10";
    inherit modDirVersion;
    defconfig = "laptop_defconfig";
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
      #QCOM_RPMPD = module;
      #QCOM_TSENS = module;
      #QCOM_STATS = module;
      #QCOM_RPMHPD = module;
      #QCOM_Q6V5_ADSP = module;
      #PHY_QCOM_QMP_PCIE_8996 = module;
      #PINCTRL_SC8280XP_LPASS_LPI = module;
    };
  };
}

#linuxManualConfig {
#  inherit (linux) version;
#  inherit modDirVersion;
#  inherit src;
#  configfile = ./laptop_defconfig_expanded;
#  extraConfig = with lib.kernel; {
#    VIDEO_AR1337 = no;
#    ANDROID_BINDER_IPC = yes;
#    ANDROID_BINDERFS = yes;
#    MEMFD_CREATE = yes;
#    DEVTMPFS = yes;
#    CGROUPS = yes;
#    INOTIFY_USER = yes;
#    SIGNALFD = yes;
#    TIMERFD = yes;
#    EPOLL = yes;
#    NET = yes;
#    SYSFS = yes;
#    PROC_FS = yes;
#    FHANDLE = yes;
#    CRYPTO_USER_API_HASH = yes;
#    CRYPTO_HMAC = yes;
#    CRYPTO_SHA256 = yes;
#    DMIID = yes;
#    AUTOFS_FS = yes;
#    TMPFS_POSIX_ACL = yes;
#    TMPFS_XATTR = yes;
#    SECCOMP = yes;
#
#    TMPFS = yes;
#    BLK_DEV_INITRD = yes;
#    MODULES = yes;
#    BINFMT_ELF = yes;
#    UNIX = yes;
#  };
#}
