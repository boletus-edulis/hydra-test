{ src
, pkgs
, lib
, stdenv
, ...
} @ args:
let
  version = "6.9.0";
in
pkgs.buildLinux (args // {
  modDirVersion = "6.9.0-rc6";
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
  };
  extraMeta.branch = "${version}-x13s";
} // (args.argsOverride or {}))
