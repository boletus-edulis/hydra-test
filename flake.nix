{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      supportedSystems = [
        #"x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      version = nixpkgs.lib.removeSuffix "\n" (builtins.readFile ./version);
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

    in
    {
      packages = forAllSystems (system:
        {
          iosevka-term = nixpkgs.legacyPackages.${system}.iosevka.override {
            set = "term";
          };
          #default = self.packages.${system}.iosevka-term;
        });
      hydraJobs = {
        #iosevka-term = forAllSystems (system: self.packages.${system}.iosevka-term);
        iosevka-term = forAllSystems (system:
          nixpkgs.legacyPackages.${system}.iosevka.override {
            set = "term";
          });
        firefox = forAllSystems (system: nixpkgs.legacyPackages.${system}.firefox);
        linux_6_5_x13s = (pkgs.linux_6_5.override {
          argsOverride = rec {
            version = "6.5";
            modDirVersion = "6.5.6";
            extraMeta.branch = lib.versions.majorMinor version;
            #modDirVersion = lib.versions.pad 3 version;

            src = pkgs.fetchFromGitHub {
              owner = "steev";
              repo = "linux";
              rev = "lenovo-x13s-linux-6.5.y";
              sha256 = "sha256-GBFjEDtoR/cwXRyaKXIDk4ksW0rrdWTGhZUDsIYY2Sw=";
            };
            defconfig = "laptop_defconfig";
          };
        });
        x13s-firmware = (pkgs.stdenv.mkDerivation {
          pname = "x13s-firmware";
          version = "9999";

          src = pkgs.fetchFromGitHub {
            owner = "ironrobin";
            repo = "x13s-alarm";
            rev = "2dcb4c8";
            sha256 = "sha256-SbqXeU2pjPb4tpDU4/UqBZ8Ev+J6P9qCO5g6no5WFwM=";
          };

          sourceRoot = "./source";
          dontBuild = true;
          # Firmware blobs do not need fixing and should not be modified
          dontFixup = true;

          nativeBuildInputs = [ pkgs.linux-firmware ];

          installPhase = ''
      runHook preInstall

      cp -vaL "${pkgs.linux-firmware}/" "$out/"
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

        qrtr = (pkgs.stdenv.mkDerivation rec {
          pname = "qrtr";
          version = "d0d471c";

          src = pkgs.fetchFromGitHub {
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

        pd-mapper = (pkgs.stdenv.mkDerivation rec {
          pname = "pd-mapper";
          version = "107104b";

          src = pkgs.fetchFromGitHub {
            owner = "andersson";
            repo = "pd-mapper";
            rev = "${version}";
            sha256 = "sha256-ypLS/g1FNi2vzIYkIoml2FkMM1Tc8UrRRhWaYbwpwkc=";
          };

          nativeBuildInputs = [
            #(pkgs.callPackage ./firmware { })
            x13s-firmware
            qrtr
          ];

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
      };
    };
}
