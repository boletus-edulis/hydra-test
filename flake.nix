{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    linux-steeve-6-8 = {
      url = "git+https://github.com/steev/linux?ref=lenovo-x13s-linux-6.8.y";
      flake = false;
    };

    linux-jhovold-6-9 = {
      url = "git+https://github.com/jhovold/linux?ref=wip/sc8280xp-6.9";
      flake = false;
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };

    emacs-overlay ={
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-parts, ... } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, lib, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (import inputs.rust-overlay)
              (import inputs.emacs-overlay)
            ];
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

          #inherit (nixpkgs.lib.customisation) hydraJob;
          # builtins.getAttr system packages
          #getNames = set: builtins.attrNames (builtins.getAttr system set);
          # transpose = set: lib.genAttrs (builtins.attrNames (builtins.getAttr system set))
          #  (name: { "${system}" = set."${name}"; });
          # hydraJobs = transpose self.packages;
          #transpose = set: (builtins.mapAttrs
          #  (name: value: { "${system}" = value;} )
          #  (lib.getAttr system set));
        in
        {
          packages = {
            inherit (pkgs) thunderbird firefox scribus libvirt k3s emacs-nox git qemu waydroid emacs-git-nox;
            inherit rustDev;
          } // {
            x13s-firmware = pkgs.callPackage ./pkgs/firmware_x13s.nix { };
            qrtr = pkgs.callPackage ./pkgs/qrtr.nix { };
            pd-mapper = pkgs.callPackage ./pkgs/pd-mapper.nix { inherit self'; };
            iosevka-term = pkgs.iosevka.override { set = "Term"; };
            linux_x13s = pkgs.callPackage ./pkgs/linux_x13s_6_8.nix {
              src = inputs.linux-steeve-6-8;
            };
            linux_x13s_6_9 = pkgs.callPackage ./pkgs/linux_x13s_6_9.nix {
              src = inputs.linux-jhovold-6-9;
            };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [ nixpkgs-fmt nil ];
          };
        };
      flake = {
        hydraJobs = self.packages;
      };
    };
}
