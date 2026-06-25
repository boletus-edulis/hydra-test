{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-parts, ... } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
	"aarch64-linux"
      ];
      perSystem = { config, self', inputs', pkgs, system, lib, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (import inputs.rust-overlay)
              #(import inputs.emacs-overlay)
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
        in
        {
          packages = {
            inherit (pkgs) thunderbird firefox scribus libvirt emacs-nox git qemu_kvm qemu-utils;
            inherit (pkgs.pkgsMusl) openssh;
            inherit rustDev;
          } // {
            x13s-firmware = pkgs.callPackage ./pkgs/firmware_x13s.nix { };
            qrtr = pkgs.callPackage ./pkgs/qrtr.nix { };
            pd-mapper = pkgs.callPackage ./pkgs/pd-mapper.nix { inherit self'; };
            #iosevka-term = pkgs.iosevka.override { set = "Term"; };
            slbounce = pkgs.callPackage ./pkgs/slbounce.nix { };
            launch = pkgs.callPackage ./pkgs/launch.nix { };
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
