{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    linux-steeve-6-14 = {
      url = "git+https://github.com/steev/linux?ref=lenovo-x13s-linux-6.14.y";
      flake = false;
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
      systems = [ "x86_64-linux" "aarch64-linux" ];
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
            inherit (pkgs) thunderbird firefox scribus libvirt k3s emacs-nox git qemu;
            inherit (pkgs.pkgsMusl) openssh;
            inherit rustDev;
          } // {
            echo-linux-version = pkgs.callPackage ./utils/echo-linux-version.nix {
              linux_pkg = self'.packages.linux_x13s;
            };

            x13s-firmware = pkgs.callPackage ./pkgs/firmware_x13s.nix { };
            qrtr = pkgs.callPackage ./pkgs/qrtr.nix { };
            pd-mapper = pkgs.callPackage ./pkgs/pd-mapper.nix { inherit self'; };
            #iosevka-term = pkgs.iosevka.override { set = "Term"; };

            linux_x13s = let
              linux_version = import ./linux_version.nix;
            in pkgs.callPackage ./pkgs/linux_x13s.nix {
              src = inputs.linux-steeve-6-14;
              version = linux_version;
              defconfig = "johan_defconfig";
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
