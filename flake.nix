{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      supportedSystems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      version = nixpkgs.lib.removeSuffix "\n" (builtins.readFile ./version);
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

    in
    {
      packages = forAllSystems (system:
        {
          default = self.packages.${system}.patchelf;
          packages.${system}.iosevka-term = nixpkgs.legacyPackages.${
            system
          }.iosevka.override { set = "term"; };
        });
      hydraJobs = {
        build = forAllSystems (system: self.packages.${system}.iosevka-term);
      };
    };
}
