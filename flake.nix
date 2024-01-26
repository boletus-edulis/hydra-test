{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-parts, ... } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, lib, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
          };
        in
        rec {
          packages = {
            inherit (pkgs) thunderbird firefox scribus libvirt k3s;
          } // {
            x13s-firmware = pkgs.callPackage ./pkgs/firmware_x13s.nix { };
            qrtr = pkgs.callPackage ./pkgs/qrtr.nix { };
            pd-mapper = pkgs.callPackage ./pkgs/pd-mapper.nix { inherit self'; };
            iosevka-term = pkgs.iosevka.override { set = "term"; };
            linux_x13s = pkgs.callPackage ./pkgs/linux_x13s.nix { };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nixpkgs-fmt
              nil
            ];
          };
        };
      flake = {
        hydraJobs = self.packages;
      };
    };
}
