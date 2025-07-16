{ pkgs, lib }:
pkgs.stdenv.mkDerivation rec {
  pname = "slbounce";
  version = "4";

  src = pkgs.fetchFromGitHub {
    owner = "TravMurav";
    repo = "slbounce";
    rev = "v${version}";
    sha256 = "sha256-395Xfc7YM3XjaLaxMz8GO2SSxKKPAmX0S6nnXi0llsg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [ gnu-efi ];

  # no install target
  dontInstall = true;

#  preBuild = ''
#    sed -i 's|/lib/firmware/|${
#      self'.packages.x13s-firmware
#    }/lib/firmware/|g' pd-mapper.c
#    grep "/lib/firmware/" pd-mapper.c
#  '';

  makeFlags = [
    "CROSS_COMPILE="
    "OUT_DIR=$(out)"
  ];

  meta = with lib; {
    description = "slbounce";
    homepage = "https://github.com/TravMurav/slbounce";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
  };
}
