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
      makeJobs = pkglist:
        (lib.attrsets.genAttrs pkglist
          (name: forAllSystems (system: nixpkgs.legacyPackages.${system}.${name})));

    in
    {
      hydraJobs = makeJobs [
        "thunderbird"
        "firefox"
        "scribus"
      ] // {
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
    };
}
