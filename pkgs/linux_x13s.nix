{ src
, pkgs
, lib
, stdenv
, version
, ...
} @ args:
let
  modDirVersion = version;
in
pkgs.buildLinux (args // {
  inherit modDirVersion;
  inherit version;
  inherit src;

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

    ZLIB_DEFLATE = yes;
  };
  extraMeta.branch = "${version}-x13s";
} // (args.argsOverride or {}))
