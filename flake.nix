{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    linux-steeve-6-7 = {
      url = "git+https://github.com/steev/linux?ref=lenovo-x13s-linux-6.7.y";
      flake = false;
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
  };

  outputs = { self, nixpkgs, flake-parts, ... } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, lib, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import inputs.rust-overlay) ];
          };
          rustVersion = "latest";
          rustBranch = "nightly";
          rustDev = pkgs.rust-bin.${rustBranch}.${rustVersion}.default.override {
            extensions = [
              "rust-src"
              "rustc-dev"
              "llvm-tools-preview"
              "rust-analyzer-preview"
            ];
          };

          # builtins.getAttr system packages
          #getNames = set: builtins.attrNames (builtins.getAttr system set);
          # transpose = set: lib.genAttrs (builtins.attrNames (builtins.getAttr system set))
          #  (name: { "${system}" = set."${name}"; });
          # hydraJobs = transpose self.packages;
          #transpose = set: (builtins.mapAttrs (name: value: { "${system}" = value;} ) (lib.getAttr system set));
        in
        {
          packages = {
            inherit (pkgs) thunderbird firefox scribus libvirt k3s emacs git
              waydroid qemu_full;
            inherit rustDev;
          } // {
            x13s-firmware = pkgs.callPackage ./pkgs/firmware_x13s.nix { };
            # qrtr = pkgs.callPackage ./pkgs/qrtr.nix { };
            # pd-mapper = pkgs.callPackage ./pkgs/pd-mapper.nix { inherit self'; };
            # iosevka-term = pkgs.iosevka.override { set = "term"; };
            # linux_x13s = pkgs.callPackage ./pkgs/linux_x13s.nix { src = inputs.linux-steeve-6-7; };
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
