{ src
, pkgs
, lib
, stdenv
, version
, defconfig
, ...
} @ args:
let
  modDirVersion = version;
in
pkgs.buildLinux (args // {
  inherit modDirVersion;
  inherit defconfig;
  inherit version;
  inherit src;

  ignoreConfigErrors = true;

  structuredExtraConfig = with lib.kernel; {
    # nixpkgs/nixos/modules/system/boot/kernel.nix wants there
    USB_PCI = yes;
    USB_UHCI_HCD = module;
    USB_EHCI_PCI = module;
    USB_OHCI_HCD_PCI = module;
    USB_XHCI_PCI = yes;

    # fix poweroff?
    POWER_RESET_SYSCON_POWEROFF = yes;
    POWER_RESET_SYSCON = yes;

    PSTORE = yes;
    PSTORE_DEFLATE_COMPRESS = yes;
    ZLIB_DEFLATE = yes;

    HID_LENOVO = module;
    I2C_HID_ACPI = module;
    ACPI = yes;

    VIRTUALIZATION = yes;
    KVM = yes;
    VHOST_NET = yes;
    HIGH_RES_TIMER = yes;
    HPET = yes;
    COMPACTION = yes;
    MIGRATION = yes;
    KSM = yes;
    SYSFS = yes;
    PROC_FS = yes;
    TRANSPARENT_HUGEPAGE = yes;
    CGROUPS = yes;
    KVM_HYPERV = yes;
  };
  extraMeta.branch = "${version}-x13s";
} // (args.argsOverride or {}))
