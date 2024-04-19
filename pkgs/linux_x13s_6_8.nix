{ src
, pkgs
, lib
, stdenv
, ...
} @ args:
let
  version = "6.8.5";
in
pkgs.buildLinux (args // {
  inherit version;
  inherit src;
  #defconfig = "laptop_defconfig";
  defconfig = "johan_defconfig";
  structuredExtraConfig = with lib.kernel; {
    # nixpkgs/nixos/modules/system/boot/kernel.nix wants there
    USB_PCI = yes;
    USB_UHCI_HCD = module;
    USB_EHCI_PCI = module;
    USB_OHCI_HCD_PCI = module;
    USB_XHCI_PCI = module;

    # fix poweroff?
    POWER_RESET_SYSCON_POWEROFF = yes;
    POWER_RESET_SYSCON = yes;

#    VIDEO_AR1337 = no;
#    AUDIT = yes;
#    ARM64_SME = yes;
#    MAC80211_LEDS = yes;
#    FW_LOADER_USER_HELPER = yes;
#    QCOM_EBI2 = yes;
#    EFI_CAPSULE_LOADER = yes;
#    SRAM = yes;
#    KEYBOARD_GPIO = yes;
#    SERIAL_QCOM_GENI = yes;
#    PINCTRL_QCOM_SPMI_PMIC = yes;
#    #QCOM_TSENS = yes;
#    BACKLIGHT_CLASS_DEVICE = yes;
#    VIRTIO_MENU = yes;
#    VHOST_MENU = yes;
#    SC_GCC_8280XP = yes;
#    SC_GPUCC_8280XP = yes;
#    #QCOM_STATS = yes;
#    QCOM_CPR = yes;
#    #QCOM_RPMHPD = yes;
#    #QCOM_RPMPD = yes;
#    #PHY_QCOM_QMP_PCIE_8996 = yes;
#    NVMEM_QCOM_QFPROM = yes;
#    CRYPTO_AES_ARM64_CE_BLK = yes;
#    CRYPTO_AES_ARM64_BS = yes;
#    CRYPTO_AES_ARM64_CE_CCM = yes;
#
#    QCOM_SSC_BLOCK_BUS = yes;
#    QCOM_QSEECOM = yes;
#    SCSI = yes;
#    I2C_QCOM_CCI = yes;
#    #GPIO_WCD934X = yes;
#    QCOM_LMH = yes;
#    #MFD_WCD934X = module;
#
#    CONFIG_CRYPTO_DEV_CCREE = module;
#
#    # put all of them in the initrd?
#    QCOM_RPMPD = module;
#    QCOM_TSENS = module;
#    QCOM_STATS = module;
#    QCOM_RPMHPD = module;
#    QCOM_Q6V5_ADSP = module;
#    PHY_QCOM_QMP_PCIE_8996 = module;
#    PINCTRL_SC8280XP_LPASS_LPI = module;
#    PHY_QCOM_QMP_USB_SNPS_FEMTO_V2 = module;
#    #QCOM_CPR = yes;
#    #INTERCONNECT = yes;
##    I2C_QCOM_CCI = module;
#
#    #ANDROID_BINDER_IPC = yes;
#    #ANDROID_BINDERFS = yes;
#    #MEMFD_CREATE = yes;
#    #DEVTMPFS = yes;
#    #CGROUPS = yes;
#    #INOTIFY_USER = yes;
#    #SIGNALFD = yes;
#    #TIMERFD = yes;
#    #EPOLL = yes;
#    #NET = yes;
#    #SYSFS = yes;
#    #PROC_FS = yes;
#    #FHANDLE = yes;
#    #CRYPTO_USER_API_HASH = yes;
#    #CRYPTO_HMAC = yes;
#    #CRYPTO_SHA256 = yes;
#    #DMIID = yes;
#    #AUTOFS_FS = yes;
#    #TMPFS_POSIX_ACL = yes;
#    #TMPFS_XATTR = yes;
#    #SECCOMP = yes;
#
#    #TMPFS = yes;
#    #BLK_DEV_INITRD = yes;
#    #MODULES = yes;
#    #BINFMT_ELF = yes;
#    #UNIX = yes;
  };
  extraMeta.branch = "${version}-x13s";
} // (args.argsOverride or {}))
