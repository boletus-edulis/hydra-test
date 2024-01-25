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
      pkgs = nixpkgs.legacyPackages;
      buildPackageAttrs = pkglist:
        forAllSystems (system:
          (lib.attrsets.genAttrs pkglist
            (name: pkgs.${system}.${name})));
    in
    rec {
      packages = forAllSystems (system: (buildPackageAttrs [
        "thunderbird"
        "firefox"
        "scribus"
        "libvirt"
      ]).${system} // rec {
        x13s-firmware = (pkgs.${system}.stdenv.mkDerivation {
          pname = "x13s-firmware";
          version = "9999";

          src = pkgs.${system}.fetchFromGitHub {
            owner = "ironrobin";
            repo = "x13s-alarm";
            rev = "2dcb4c8";
            sha256 = "sha256-SbqXeU2pjPb4tpDU4/UqBZ8Ev+J6P9qCO5g6no5WFwM=";
          };

          sourceRoot = "./source";
          dontBuild = true;
          # Firmware blobs do not need fixing and should not be modified
          dontFixup = true;

          nativeBuildInputs = [ pkgs.${system}.linux-firmware ];

          installPhase = ''
            runHook preInstall

            cp -vaL "${pkgs.${system}.linux-firmware}/" "$out/"
            chmod -R +w "$out/"

            mkdir -p "$out/lib/firmware/qcom/sc8280xp/LENOVO/21BX"
            cp -fv "x13s-firmware/qcvss8280.mbn" \
               "$out/lib/firmware/qcom/sc8280xp/LENOVO/21BX"

            mkdir -p "$out/lib/firmware/qca"
            cp -fv "x13s-firmware/hpnv21.b8c" "$out/lib/firmware/qca"
            cp -fv "x13s-firmware/a690_gmu.bin" "$out/lib/firmware/qcom"
            # cp -fv "$out/lib/firmware/qcom/sc8280xp/LENOVO/21BX/audioreach-tplg.bin" \
            #    "$out/lib/firmware/qcom/sc8280xp/SC8280XP-LENOVO-X13S-tplg.bin"

            runHook postInstall
          '';

          meta = with lib; {
            description = "Firmware for Lenovo Thinkpad X13s";
            homepage = "https://github.com/ironrobin/x13s-alarm";
            license = licenses.unfreeRedistributableFirmware;
            platforms = platforms.linux;
          };
        });
        qrtr = (pkgs.${system}.stdenv.mkDerivation rec {
          pname = "qrtr";
          version = "d0d471c";

          src = pkgs.${system}.fetchFromGitHub {
            owner = "andersson";
            repo = "qrtr";
            rev = "${version}";
            sha256 = "sha256-KF0gCBRw3BDJdK1s+dYhHkokVTHwRFO58ho0IwHPehc=";
          };

          makeFlags = [
            "CC=gcc"
            "prefix=$(out)"
          ];

          meta = with lib; {
            description = "qrtr";
            homepage = "https://github.com/andersson/qrtr";
            license = licenses.unfreeRedistributableFirmware;
            platforms = platforms.linux;
          };
        });
        pd-mapper = (pkgs.${system}.stdenv.mkDerivation rec {
          pname = "pd-mapper";
          version = "107104b";

          src = pkgs.${system}.fetchFromGitHub {
            owner = "andersson";
            repo = "pd-mapper";
            rev = "${version}";
            sha256 = "sha256-ypLS/g1FNi2vzIYkIoml2FkMM1Tc8UrRRhWaYbwpwkc=";
          };

          nativeBuildInputs = [ x13s-firmware qrtr ];

          preBuild = ''
            sed -i 's|/lib/firmware/|${
              #(pkgs.callPackage ./firmware { })
              x13s-firmware
            }/lib/firmware/|g' pd-mapper.c
            grep "/lib/firmware/" pd-mapper.c
          '';

          makeFlags = [
            "CC=gcc"
            "prefix=$(out)"
          ];

          meta = with lib; {
            description = "pd-mapper";
            homepage = "https://github.com/andersson/pd-mapper";
            license = licenses.unfreeRedistributableFirmware;
            platforms = platforms.linux;
          };
        });
        iosevka-term = pkgs.${system}.iosevka.override { set = "term"; };
        linux_6_7_x13s = pkgs.${system}.linux_6_7.override {
          argsOverride = rec {
            modDirVersion = "6.7.1";
            src = pkgs.${system}.fetchFromGitHub {
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
              USB_EHCI_HCD = yes;
              USB_EHCI_HCD_ORION = module;
              USB_EHCI_HCD_PLATFORM = module;
              USB_OHCI_HCD = yes;
              USB_OHCI_HCD_PLATFORM = yes;
              USB_U132_HCD = module;
              USBIP_VHCI_HCD = module;
              SCSI_UFSHCD = yes;
              SCSI_UFSHCD_PCI = module;
              SCSI_UFSHCD_PLATFORM = yes;
            };
          };
        };
        linux_x13s = linux_6_7_x13s;
      });

      hydraJobs = packages;
    };
}
