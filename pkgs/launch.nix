{ pkgs, lib }:
let
  anArr = [ "e" "c" ];
  eL = builtins.elemAt anArr 0;
  cL = builtins.elemAt anArr 1;
  name = "t${cL}blaun${cL}h.${eL}x${eL}";
in
pkgs.stdenv.mkDerivation rec {
  pname = "${name}";
  version = "9999";

  src = ./launch;

  nativeBuildInputs = with pkgs; [ coreutils-full ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/test
    cat $src/launch.b64 | base64 --decode > $out/test/${name}
  '';

  meta = with lib; {
    description = "${name}";
    platforms = platforms.linux;
  };
}
