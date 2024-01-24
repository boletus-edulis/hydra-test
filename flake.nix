{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      # version = nixpkgs.lib.removeSuffix "\n" (builtins.readFile ./version);
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      lib = nixpkgs.lib;
      buildPackageAttrs = pkglist:
        forAllSystems (system:
          (lib.attrsets.genAttrs pkglist
            (name: nixpkgs.legacyPackages.${system}.${name})));
    in
    rec {
      packages = forAllSystems (system: (buildPackageAttrs [
        "thunderbird"
        "firefox"
        "scribus"
      ]).${system} // {
        iosevka-term = nixpkgs.legacyPackages.${system}.iosevka.override { set = "term"; };
        linux_6_7_x13s = nixpkgs.legacyPackages.${system}.linux_6_7.override {
          argsOverride = rec {
            modDirVersion = "6.7.1";
            src = nixpkgs.legacyPackages.${system}.fetchFromGitHub {
              owner = "steev";
              repo = "linux";
              rev = "lenovo-x13s-linux-6.7.y";
              sha256 = "sha256-z7+/4n1RyDXfs98LPOUUw8Xm05yDC53smWFCa3UGQfQ=";
            };
            #defconfig = "laptop_defconfig";
            defconfig = "johan_defconfig";
            structuredExtraConfig = with lib.kernel; {
              VIDEO_AR1337 = no;
              AUDIT = yes;
              ARM64_SME = yes;
              CPU_IDLE = yes;
              IPV6 = yes;
              NETFILTER_XTABLES_COMPAT = yes;
              NETFILTER_XT_MARK = module;
              IP6_NF_IPTABLES = module;
              IP6_NF_FILTER = module;
              IP6_NF_TARGET_REJECT = module;
              MAC80211_LEDS = yes;
              FW_LOADER_USER_HELPER = yes;
              EFI_CAPSULE_LOADER = yes;
              SRAM = yes;
              QCOM_TSENS = yes;
              NEW_LEDS = yes;
              LEDS_GPIO = yes;
              LEDS_SYSCON = yes;
              LEDS_TRIGGER_HEARTBEAT = yes;
              SC_GCC_8280XP = yes;
              SC_GPUCC_8280XP = module;
              QCOM_Q6V5_ADSP = module;
              QCOM_CPR = yes;
              QCOM_RPMHPD = yes;
              QCOM_RPMPD = yes;
              PHY_QCOM_QMP = yes;
              PHY_QCOM_QMP_PCIE_8996 = yes;
              NVMEM_QCOM_QFPROM = yes;
              INTERCONNECT = yes;
              CONFIGFS_FS = yes;
              EFIVAR_FS = yes;
              NETWORK_FILESYSTEMS = yes;
              NLS_ASCII = yes;
              LSM = freeform "landlock,lockdown,yama,loadpin,safesetid,integrity,bpf";
              CRYPTO_NULL = yes;
              CRYPTO_DES = module;
              CRYPTO_MICHAEL_MIC = module;
              CRYPTO_ANSI_CPRNG = yes;
              DEBUG_KERNEL = yes;
              DEBUG_FS = yes;
            };
          };
        };
      });

      hydraJobs = packages;
    };
}
