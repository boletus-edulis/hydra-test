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
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

    in
    {
      hydraJobs = {
        iosevka-term = forAllSystems (system:
          nixpkgs.legacyPackages.${system}.iosevka.override {
            set = "term";
          }
        );
        firefox = forAllSystems (system:
          nixpkgs.legacyPackages.${system}.firefox
        );
        linux_6_6_x13s = forAllSystems (system:
          nixpkgs.legacyPackages.${system}.linux_6_6.override {
            argsOverride = rec {
              modDirVersion = "6.6.2";
              src = nixpkgs.legacyPackages.${system}.fetchFromGitHub {
                owner = "steev";
                repo = "linux";
                rev = "lenovo-x13s-linux-6.6.y";
                sha256 = "sha256-lEw/AaEeOGClMP/pWLZ2RMGnr1ypBW6sLjCK961sDeI=";
              };

              defconfig = "laptop_defconfig";
            };
          }
        );
      };
    };
}
