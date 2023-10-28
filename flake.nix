{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux.pkgs;
    in {
      packages.iosevka-term = pkgs.iosevka.override { set = "term"; };
    };
}
