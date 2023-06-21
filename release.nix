{ nixpkgs }:
let
  pkgs = import nixpkgs {};
in {
  iosevka-term = pkgs.iosevka.override {
    set = "term";
  };
}
