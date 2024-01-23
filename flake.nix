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
      makeJobs = pkglist:
        (lib.attrsets.genAttrs pkglist
          (name: forAllSystems (system: nixpkgs.legacyPackages.${system}.${name})));

      pkgNames = [
        "thunderbird"
        "firefox"
        "scribus"
      ];

    in
    rec {
      hydraJobs = makeJobs pkgNames // {
        iosevka-term = forAllSystems (system:
          nixpkgs.legacyPackages.${system}.iosevka.override { set = "term"; });
        linux_6_7_x13s = forAllSystems (system:
          nixpkgs.legacyPackages.${system}.linux_6_7.override {
            argsOverride = rec {
              modDirVersion = "6.7.1";
              src = nixpkgs.legacyPackages.${system}.fetchFromGitHub {
                owner = "steev";
                repo = "linux";
                rev = "lenovo-x13s-linux-6.7.y";
                sha256 = "sha256-z7+/4n1RyDXfs98LPOUUw8Xm05yDC53smWFCa3UGQfQ=";
              };
              defconfig = "laptop_defconfig";
            };
          });
      };

      packages = forAllSystems
        (system: lib.genAttrs (lib.attrNames hydraJobs)
          (job: hydraJobs.${job}.${system}));
    };
}
